
class RecommendationsController < ApplicationController
  before_action :authenticate_user!

  # GET /recommendations
  def index
    unless current_user.user_preference
      redirect_to edit_user_preferences_path, alert: 'Please set your preferences first to get recommendations.'
      return
    end

    
    content_based = PetRecommendationService.new(current_user).call
    collaborative_pets = CollaborativeRecommendationService.new(current_user, limit: 5).call  # [Pet, ...]
    seen_ids = content_based.map { |item| item[:pet].id }.to_set
    collaborative_items = collaborative_pets.reject { |pet| seen_ids.include?(pet.id) }.map do |pet|
      {
        pet: pet,
        score: 0,
        match_percentage: 0,
        collaborative: true
      }
    end

    @recommended_pets = content_based + collaborative_items
  end
end
