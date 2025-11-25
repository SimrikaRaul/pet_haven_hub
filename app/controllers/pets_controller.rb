class PetsController < ApplicationController
  #skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_pet, only: [:show, :adopt, :create_request]

  def index
    @pets = Pet.available.recent
    
    # Apply filters
    @pets = @pets.by_species(params[:species]) if params[:species].present?
    @pets = @pets.by_breed(params[:breed]) if params[:breed].present?
    @pets = @pets.by_size(params[:size]) if params[:size].present?
    @pets = @pets.by_age_max(params[:max_age]) if params[:max_age].present?
    
    # Search by name
    @pets = @pets.where('LOWER(name) LIKE ?', "%#{params[:search].downcase}%") if params[:search].present?
    
    # Location-based search (if coordinates provided)
    if params[:latitude].present? && params[:longitude].present?
      @pets = @pets.near_location(params[:latitude], params[:longitude], params[:radius] || 50)
    end
    
    # Pagination
    @pets = @pets.page(params[:page]).per(12)
    
    # Get available species for filter dropdown
    @available_species = Pet.select(:pet_type).distinct.map(&:pet_type)
    @available_breeds = Pet.select(:breed).distinct.map(&:breed)
    
    respond_to do |format|
      format.html
      format.json { render json: @pets }
    end
  end

  def show
    authorize @pet, :show?
    @request = Request.new
    @similar_pets = Recommendations::ContentBasedService.call(user: current_user, pet: @pet, limit: 4) if user_signed_in?
  end

  private

  def set_pet
    @pet = Pet.find(params[:id])
  end
end
