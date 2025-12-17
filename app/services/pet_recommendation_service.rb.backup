class PetRecommendationService
  # Attribute weights for scoring algorithm
  ATTRIBUTE_WEIGHTS = {
    pet_type: 10,
    size: 6,
    energy_level: 7,
    temperament: 7,
    affectionate: 5,
    social_with_children: 6,
    social_with_other_pets: 4,
    trainability: 4,
    grooming_needs: 4,
    exercise_needs: 4,
    apartment_friendly: 5,
    vaccinated: 3
  }.freeze

  def initialize(preferences = {})
    @preferences = preferences.symbolize_keys
    @limit = @preferences.delete(:limit) || 5
    @require_vaccinated = @preferences.delete(:require_vaccinated) || false
  end

  # Main method to get recommended pets
  # Returns array of hashes: [{ pet: <Pet>, score: <Integer> }, ...]
  def recommend
    pets = fetch_eligible_pets
    scored_pets = score_pets(pets)
    sorted_pets = sort_by_score(scored_pets)
    top_recommendations(sorted_pets)
  end

  private

  # Fetch pets that match basic filtering criteria
  def fetch_eligible_pets
    pets = Pet.available
    
    # Apply required vaccinated filter if specified
    pets = pets.vaccinated if @require_vaccinated
    
    # Apply pet_type filter if specified (high priority)
    pets = pets.where(pet_type: @preferences[:pet_type]) if @preferences[:pet_type].present?
    
    pets
  end

  # Calculate score for each pet based on preference matching
  def score_pets(pets)
    pets.map do |pet|
      score = calculate_pet_score(pet)
      { pet: pet, score: score }
    end
  end

  # Calculate individual pet score by comparing all attributes to preferences
  def calculate_pet_score(pet)
    total_score = 0

    ATTRIBUTE_WEIGHTS.each do |attribute, weight|
      # Skip if user didn't specify preference for this attribute
      next unless @preferences.key?(attribute)

      preference_value = @preferences[attribute]
      pet_value = pet.send(attribute)

      # Add weighted points if attribute matches preference
      if attribute_matches?(pet_value, preference_value)
        total_score += weight
      end
    end

    total_score
  end

  # Determine if pet attribute matches user preference
  def attribute_matches?(pet_value, preference_value)
    # Handle nil values
    return false if pet_value.nil?
    
    # Handle boolean comparisons
    if [true, false].include?(preference_value)
      return pet_value == preference_value
    end

    # Handle string/enum comparisons (case-insensitive)
    if pet_value.is_a?(String) && preference_value.is_a?(String)
      return pet_value.downcase == preference_value.to_s.downcase
    end

    # Handle array of acceptable values
    if preference_value.is_a?(Array)
      return preference_value.map(&:to_s).map(&:downcase).include?(pet_value.to_s.downcase)
    end

    # Default comparison
    pet_value == preference_value
  end

  # Sort pets by score in descending order
  def sort_by_score(scored_pets)
    scored_pets.sort_by { |item| -item[:score] }
  end

  # Return top N recommendations
  def top_recommendations(sorted_pets)
    sorted_pets.take(@limit)
  end
end
