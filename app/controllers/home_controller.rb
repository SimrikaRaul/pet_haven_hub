class HomeController < ApplicationController
  def index
    # Show only truly available pets (not in_process or adopted)
    @featured_pets = Pet.available.recent.limit(8)
    @total_pets = Pet.available.count
    @total_adopted = Pet.adopted.count
    @total_in_process = Pet.in_process.count

    # Collaborative filtering recommendations for logged-in users
    if user_signed_in?
      @recommended_pets = CollaborativeFilteringService.new(current_user, limit: 8).call
    end
  end

  def about
  end
end
