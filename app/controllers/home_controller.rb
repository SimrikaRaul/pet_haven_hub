class HomeController < ApplicationController
  def index
    @featured_pets = Pet.where(available: true).recent.limit(8)
    @total_pets = Pet.where(available: true).count
    @total_adopted = Pet.where(available: false).count

    # Collaborative filtering recommendations for logged-in users
    if user_signed_in?
      @recommended_pets = CollaborativeFilteringService.new(current_user, limit: 8).call
    end
  end

  def about
  end
end
