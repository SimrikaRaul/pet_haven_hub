
class RecommendationsController < ApplicationController
  before_action :authenticate_user!

  # GET /recommendations
  def index
    unless current_user.user_preference
      redirect_to edit_user_preferences_path, alert: 'Please set your preferences first to get recommendations.'
      return
    end

    # Use HybridRecommendationService for combined content + collaborative filtering
  
    debug_mode = Rails.env.development? || params[:debug].present?
    
    hybrid_results = HybridRecommendationService.new(
      current_user, 
      limit: 10, 
      debug: debug_mode
    ).recommend
    
    # Format results for the view
    if hybrid_results.first.is_a?(Hash)
      # Debug mode returns hashes with scores
      @recommended_pets = hybrid_results.map do |item|
        {
          pet: item[:pet],
          score: item[:final_score] || 0,
          match_percentage: item[:final_score]&.round(0) || 0,
          content_score: item[:content_score],
          collaborative_score: item[:collaborative_score]
        }
      end
    else
      # Normal mode returns pet records
      @recommended_pets = hybrid_results.map do |pet|
        {
          pet: pet,
          score: 0,
          match_percentage: 0
        }
      end
    end
    
    # Log for debugging
    Rails.logger.info "[Recommendations] Generated #{@recommended_pets.count} recommendations for user #{current_user.id}"
  end
end
