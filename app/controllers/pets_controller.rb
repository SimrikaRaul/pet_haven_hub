class PetsController < ApplicationController
  #skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_pet, only: [:show]

  def index
    # Start with all available pets
    @pets = Pet.available.recent
    
    # Preload requests to avoid N+1 queries when checking approval status
    @pets = @pets.includes(:requests) if user_signed_in?
    
    Rails.logger.info "[Pets#index] Starting with #{@pets.count} available pets"
    
    # Apply strict filters (species, breed, size, etc.)
    @pets = @pets.by_species(params[:species]) if params[:species].present?
    Rails.logger.info "[Pets#index] After species filter (#{params[:species]}): #{@pets.count}" if params[:species].present?
    
    @pets = @pets.by_breed(params[:breed]) if params[:breed].present?
    Rails.logger.info "[Pets#index] After breed filter (#{params[:breed]}): #{@pets.count}" if params[:breed].present?
    
    @pets = @pets.by_size(params[:size]) if params[:size].present?
    Rails.logger.info "[Pets#index] After size filter (#{params[:size]}): #{@pets.count}" if params[:size].present?
    
    @pets = @pets.by_sex(params[:sex]) if params[:sex].present?
    @pets = @pets.by_age_max(params[:max_age]) if params[:max_age].present?
    @pets = @pets.where('LOWER(name) LIKE ?', "%#{params[:search].downcase}%") if params[:search].present?
    
    Rails.logger.info "[Pets#index] After all filters: #{@pets.count} pets"
    Rails.logger.info "[Pets#index] has_preference_params? = #{has_preference_params?}"
    
    # If user has preference parameters, score and sort the FILTERED pets
    if user_signed_in? && has_preference_params?
      save_user_preferences
      
      # Score the already-filtered pets (not all pets!)
      scored_pets = score_filtered_pets(@pets)
      Rails.logger.info "[Pets#index] Scored #{scored_pets.count} pets"
      
      if scored_pets.any?
        # Sort by score descending
        pets_array = scored_pets.sort_by { |item| -item[:score] }.map { |item| item[:pet] }
        @scored_pets_hash = scored_pets.index_by { |item| item[:pet].id }
        @pets = Kaminari.paginate_array(pets_array).page(params[:page]).per(10)
        Rails.logger.info "[Pets#index] Final paginated count: #{@pets.size}"
      else
        # No pets match filters at all - show empty with message
        Rails.logger.info "[Pets#index] No scored pets, using original filtered list"
        @pets = @pets.page(params[:page]).per(10)
      end
    else
      @pets = @pets.page(params[:page]).per(10)
    end
  
    @available_species = Pet.select(:pet_type).distinct.map(&:pet_type)
    @available_breeds = Pet.select(:breed).distinct.map(&:breed)
    
    respond_to do |format|
      format.html
      format.json { render json: @pets }
    end
  end

  def show
    authorize @pet, :show?
    
    # If pet is unavailable, show a message
    if @pet.in_process?
      flash.now[:notice] = "This pet is currently in the adoption process with another user."
    elsif @pet.adopted?
      flash.now[:notice] = "This pet has already been adopted. Check out our other available pets!"
    end
    
    @request = Request.new
    @similar_pets = Recommendations::ContentBasedService.call(user: current_user, pet: @pet, limit: 4) if user_signed_in?
    
    # Record view interaction for recommendations (low weight)
    Interaction.record_view(current_user, @pet) if user_signed_in?
  end

  private

  def set_pet
    # Preload requests for show action to avoid N+1 queries when checking approval status
    if action_name == 'show' && user_signed_in?
      @pet = Pet.includes(:requests).find(params[:id])
    else
      @pet = Pet.find(params[:id])
    end
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

  # Score filtered pets based on user preferences
  # This scores ALL filtered pets (not just top 5) so filtering works correctly
  def score_filtered_pets(pets_scope)
    pref = current_user.user_preference
    return [] unless pref
    
    pets_scope.map do |pet|
      score = 0
      max_score = 0
      
      # Energy level (weight: 3)
      if params[:preferred_energy_level].present?
        max_score += 3
        score += score_level_match(params[:preferred_energy_level], pet.energy_level, 3)
      end
      
      # Temperament (weight: 3)
      if params[:preferred_temperament].present?
        max_score += 3
        score += score_temperament_match(params[:preferred_temperament], pet.temperament, 3)
      end
      
      # Grooming needs (weight: 2)
      if params[:preferred_grooming_needs].present?
        max_score += 2
        score += score_level_match(params[:preferred_grooming_needs], pet.grooming_needs, 2)
      end
      
      # Exercise needs (weight: 2)
      if params[:preferred_exercise_needs].present?
        max_score += 2
        score += score_level_match(params[:preferred_exercise_needs], pet.exercise_needs, 2)
      end
      
      # Boolean preferences (weight: 1 each)
      if params[:wants_affectionate_pet] == '1'
        max_score += 1
        score += 1 if pet.affectionate
      end
      
      if params[:apartment_friendly_required] == '1'
        max_score += 1
        score += 1 if pet.apartment_friendly
      end
      
      if params[:kids_in_home] == '1'
        max_score += 1
        score += 1 if pet.kids_friendly || pet.social_with_children
      end
      
      if params[:has_other_pets] == '1'
        max_score += 1
        score += 1 if pet.social_with_other_pets
      end
      
      match_percentage = max_score > 0 ? ((score.to_f / max_score) * 100).round : 0
      
      {
        pet: pet,
        score: score,
        match_percentage: match_percentage
      }
    end
  end

  def score_level_match(preferred, actual, weight)
    return 0 if preferred.blank? || actual.blank?
    
    levels = { 'low' => 1, 'medium' => 2, 'high' => 3 }
    pref_val = levels[preferred.to_s.downcase] || 2
    actual_val = levels[actual.to_s.downcase] || 2
    
    diff = (pref_val - actual_val).abs
    case diff
    when 0 then weight        # Perfect match
    when 1 then weight * 0.5  # Close match
    else 0                    # No match
    end
  end

  def score_temperament_match(preferred, actual, weight)
    return 0 if preferred.blank? || actual.blank?
    return weight if preferred.downcase == actual.downcase
    
    # Compatible temperaments
    compatible = {
      'calm' => ['friendly'],
      'friendly' => ['calm', 'active'],
      'active' => ['friendly'],
      'shy' => ['calm']
    }
    
    if compatible[preferred.downcase]&.include?(actual.downcase)
      weight * 0.6
    else
      0
    end
  end
end
