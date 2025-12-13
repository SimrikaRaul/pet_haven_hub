class HomeController < ApplicationController
  def index
    @featured_pets = Pet.where(available: true).recent.limit(8)
    @total_pets = Pet.where(available: true).count
    @total_adopted = Pet.where(available: false).count
  end
end
