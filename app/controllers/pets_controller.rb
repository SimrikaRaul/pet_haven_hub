class PetsController < ApplicationController
  #skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_pet, only: [:show, :adopt, :create_request]

  def index
    @pets = Pet.available.recent

    # Apply optional filters (species, breed, size, sex)
    @pets = @pets.by_species(params[:species]) if params[:species].present?
    @pets = @pets.by_breed(params[:breed]) if params[:breed].present?
    @pets = @pets.by_size(params[:size]) if params[:size].present?
    @pets = @pets.by_sex(params[:sex]) if params[:sex].present?

    # Keep existing optional filters/search/location if present
    @pets = @pets.by_age_max(params[:max_age]) if params[:max_age].present?
    @pets = @pets.where('LOWER(name) LIKE ?', "%#{params[:search].downcase}%") if params[:search].present?
    if params[:latitude].present? && params[:longitude].present?
      @pets = @pets.near_location(params[:latitude], params[:longitude], params[:radius] || 50)
    end

    # Handle user preferences for recommendation scoring
    if user_signed_in? && has_preference_params?
      # Save or update user preferences
      save_user_preferences
      
      # Get scored recommendations
      scored_pets = PetRecommendationService.new(current_user).call
      
      # Extract pet IDs from scored results to maintain filter
      if scored_pets.any?
        scored_pet_ids = scored_pets.map { |item| item[:pet].id }
        # Filter pets to only include scored ones, maintaining ActiveRecord relation
        @pets = @pets.where(id: scored_pet_ids)
        
        # Convert to array and manually sort by recommendation score
        pets_array = @pets.to_a
        @scored_pets_hash = scored_pets.index_by { |item| item[:pet].id }
        pets_array.sort_by! { |pet| -(@scored_pets_hash[pet.id]&.dig(:score) || 0) }
        
        # Paginate manually
        @pets = Kaminari.paginate_array(pets_array).page(params[:page]).per(10)
      end
    else
      # Standard pagination without scoring
      @pets = @pets.page(params[:page]).per(10)
    end
    
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

  def has_preference_params?
    params[:preferred_energy_level].present? ||
    params[:preferred_temperament].present? ||
    params[:preferred_grooming_needs].present? ||
    params[:preferred_exercise_needs].present? ||
    params[:wants_affectionate_pet].present? ||
    params[:apartment_friendly_required].present? ||
    params[:kids_in_home].present? ||
    params[:has_other_pets].present?
  end

  def save_user_preferences
    preference = current_user.user_preference || current_user.build_user_preference
    
    preference.update(
      preferred_energy_level: params[:preferred_energy_level],
      preferred_temperament: params[:preferred_temperament],
      preferred_grooming_needs: params[:preferred_grooming_needs],
      preferred_exercise_needs: params[:preferred_exercise_needs],
      wants_affectionate_pet: params[:wants_affectionate_pet] == '1',
      apartment_friendly_required: params[:apartment_friendly_required] == '1',
      kids_in_home: params[:kids_in_home] == '1',
      has_other_pets: params[:has_other_pets] == '1'
    )
  end
end
