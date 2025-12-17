# Pet Recommendations Controller
# Displays recommended pets based on user preferences
class RecommendationsController < ApplicationController
  before_action :authenticate_user!

  # GET /recommendations
  def index
    # Check if user has preferences set
    unless current_user.user_preference
      redirect_to edit_user_preferences_path, alert: 'Please set your preferences first to get recommendations.'
      return
    end

    # Get recommended pets using the recommendation service
    @recommended_pets = PetRecommendationService.new(current_user).call
  end
end
