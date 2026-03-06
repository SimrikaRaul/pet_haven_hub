module Admin
  class DashboardController < Admin::BaseController
    def index
      @stats = {
        total_pets: Pet.count,
        available_pets: Pet.available.count,
        unavailable_pets: Pet.unavailable.count,
        adopted_pets: Pet.where(status: 'adopted').count,
        total_users: User.count,
        total_requests: Request.count,
        open_requests: Request.where(status: 'open').count,
        approved_requests: Request.where(status: 'approved').count,
        rejected_requests: Request.where(status: 'rejected').count,
        completed_requests: Request.where(status: 'completed').count,
        adoption_requests: Request.where(request_type: 'adopt').count,
        donation_requests: Request.where(request_type: 'donate').count,
        total_interactions: Interaction.count,
        total_views: Interaction.where(action: 'view').count,
        total_likes: Interaction.where(action: 'like').count,
        total_wishlist: Interaction.where(action: 'wishlist').count
      }

      # Interaction analytics (also available as standalone variables)
      @total_views = @stats[:total_views]
      @total_likes = @stats[:total_likes]
      @total_wishlist = @stats[:total_wishlist]

      @recent_pets = Pet.recent.limit(5)
      @recent_requests = Request.recent.limit(10)
      @pending_requests = Request.where(status: 'open').limit(10)
      
      # Activity chart data
      @requests_by_date = Request.group_by_day(:created_at).count.to_a.last(30).to_h
      @adoptions_by_pet_type = Request.where(request_type: 'adopt').joins(:pet).group('pets.pet_type').count

      # Pet popularity analytics
      @most_liked_pets = Pet.joins(:interactions)
                            .where(interactions: { action: 'like' })
                            .group('pets.id')
                            .order('COUNT(interactions.id) DESC')
                            .limit(5)
                            .select('pets.*, COUNT(interactions.id) AS likes_count')

      @most_wishlisted_pets = Pet.joins(:interactions)
                                .where(interactions: { action: 'wishlist' })
                                .group('pets.id')
                                .order('COUNT(interactions.id) DESC')
                                .limit(5)
                                .select('pets.*, COUNT(interactions.id) AS wishlists_count')

      # Recommendation insights
      # Estimate total recommendations as the number of high-engagement interactions
      # (likes + wishlists + adoptions), which are the outcomes of recommendation exposure.
      @recommendation_insights = {
        total_recommendations: Interaction.high_engagement.count,
        users_with_recommendations: Interaction.high_engagement.distinct.count(:user_id),
        users_with_preferences: UserPreference.count,
        avg_interactions_per_user: begin
          engaged_users = Interaction.high_engagement.distinct.count(:user_id)
          engaged_users > 0 ? (Interaction.high_engagement.count.to_f / engaged_users).round(1) : 0
        end
      }

      @most_recommended_pets = Pet.joins(:interactions)
                                  .where(interactions: { action: ['like', 'wishlist'] })
                                  .group('pets.id')
                                  .order('SUM(interactions.weight) DESC')
                                  .limit(5)
                                  .select('pets.*, SUM(interactions.weight) AS engagement_score, COUNT(interactions.id) AS interaction_count')
    end

  end
end
