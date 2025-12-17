# Pet Recommendation Service
# Calculates similarity scores between user preferences and pet attributes
# Returns top 5 recommended pets based on weighted scoring
class PetRecommendationService
  # Weights for each attribute (higher = more important)
  ATTRIBUTE_WEIGHTS = {
    energy_level: 3,
    temperament: 3,
    grooming_needs: 2,
    exercise_needs: 2,
    affectionate: 1,
    apartment_friendly: 1,
    kids_friendly: 1,
    good_with_other_pets: 1
  }.freeze

  # Maximum possible score (for normalization)
  MAX_SCORE = (
    ATTRIBUTE_WEIGHTS[:energy_level] +
    ATTRIBUTE_WEIGHTS[:temperament] +
    ATTRIBUTE_WEIGHTS[:grooming_needs] +
    ATTRIBUTE_WEIGHTS[:exercise_needs] +
    ATTRIBUTE_WEIGHTS[:affectionate] +
    ATTRIBUTE_WEIGHTS[:apartment_friendly] +
    ATTRIBUTE_WEIGHTS[:kids_friendly] +
    ATTRIBUTE_WEIGHTS[:good_with_other_pets]
  ).freeze

  def initialize(user)
    @user = user
    @preferences = user.user_preference
  end

  # Main method - returns array of recommended pets with scores
  def call
    return [] unless @preferences

    # Get all available pets
    eligible_pets = Pet.where(available: true)

    # Calculate score for each pet
    scored_pets = eligible_pets.map do |pet|
      {
        pet: pet,
        score: calculate_pet_score(pet),
        match_percentage: calculate_match_percentage(pet)
      }
    end

    # Sort by score (highest first) and return top 5
    scored_pets.sort_by { |item| -item[:score] }.first(5)
  end

  private

  # Calculate total similarity score for a pet
  def calculate_pet_score(pet)
    score = 0

    # Energy level comparison (3 points max)
    score += compare_categorical_attributes(
      @preferences.preferred_energy_level,
      pet.energy_level,
      ATTRIBUTE_WEIGHTS[:energy_level]
    )

    # Temperament comparison (3 points max)
    score += compare_temperament(
      @preferences.preferred_temperament,
      pet.temperament,
      ATTRIBUTE_WEIGHTS[:temperament]
    )

    # Grooming needs comparison (2 points max)
    score += compare_categorical_attributes(
      @preferences.preferred_grooming_needs,
      pet.grooming_needs,
      ATTRIBUTE_WEIGHTS[:grooming_needs]
    )

    # Exercise needs comparison (2 points max)
    score += compare_categorical_attributes(
      @preferences.preferred_exercise_needs,
      pet.exercise_needs,
      ATTRIBUTE_WEIGHTS[:exercise_needs]
    )

    # Affectionate comparison (1 point max)
    score += compare_boolean_attributes(
      @preferences.wants_affectionate_pet,
      pet.affectionate,
      ATTRIBUTE_WEIGHTS[:affectionate]
    )

    # Apartment friendly comparison (1 point max)
    score += compare_boolean_attributes(
      @preferences.apartment_friendly_required,
      pet.apartment_friendly,
      ATTRIBUTE_WEIGHTS[:apartment_friendly]
    )

    # Kids friendly comparison (1 point max)
    score += compare_boolean_attributes(
      @preferences.kids_in_home,
      pet.kids_friendly || pet.social_with_children,
      ATTRIBUTE_WEIGHTS[:kids_friendly]
    )

    # Good with other pets comparison (1 point max)
    score += compare_boolean_attributes(
      @preferences.has_other_pets,
      pet.social_with_other_pets,
      ATTRIBUTE_WEIGHTS[:good_with_other_pets]
    )

    score
  end

  # Compare categorical attributes (low, medium, high)
  # Returns full weight if exact match, partial weight if close
  def compare_categorical_attributes(user_pref, pet_attr, weight)
    return 0 if user_pref.blank? || pet_attr.blank?

    # Convert to numeric scores (low=1, medium=2, high=3)
    user_score = level_to_score(user_pref)
    pet_score = level_to_score(pet_attr)

    # Calculate difference
    difference = (user_score - pet_score).abs

    case difference
    when 0
      weight # Perfect match
    when 1
      weight * 0.5 # Close match
    else
      0 # No match
    end
  end

  # Compare temperament (special logic for compatible temperaments)
  def compare_temperament(user_pref, pet_temp, weight)
    return 0 if user_pref.blank? || pet_temp.blank?

    # Exact match
    return weight if user_pref == pet_temp

    # Compatible temperaments get partial score
    compatible_pairs = {
      'calm' => ['friendly'],
      'friendly' => ['calm', 'playful'],
      'playful' => ['friendly']
    }

    if compatible_pairs[user_pref]&.include?(pet_temp)
      weight * 0.6
    else
      0
    end
  end

  # Compare boolean attributes
  # If user wants it (true), pet must have it for full score
  # If user doesn't need it (false), pet can have it or not (partial score)
  def compare_boolean_attributes(user_pref, pet_attr, weight)
    # If user wants this attribute
    if user_pref
      # Pet must have it for full score
      pet_attr ? weight : 0
    else
      # User doesn't require it, give partial score regardless
      weight * 0.5
    end
  end

  # Convert level string to numeric score
  def level_to_score(level)
    case level
    when 'low' then 1
    when 'medium' then 2
    when 'high' then 3
    else 0
    end
  end

  # Calculate match percentage for display
  def calculate_match_percentage(pet)
    score = calculate_pet_score(pet)
    ((score.to_f / MAX_SCORE) * 100).round
  end
end
