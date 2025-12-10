# Content-based recommendation service
# Builds simple feature vectors for pets and computes cosine similarity
require_relative '../application_service'

class Recommendations::ContentBasedService < ApplicationService
  def initialize(user:, pets: nil, pet: nil, limit: 10)
    @user = user
    # Accept either a collection via `pets:` or a single `pet:` (caller convenience).
    # If a single `pet` is provided, recommend other pets excluding that pet.
    if pets.present?
      @pets = pets
    elsif pet.present?
      @pets = Pet.where.not(id: pet.id)
    else
      @pets = Pet.all
    end
    @limit = limit
  end

  def call
    # Placeholder implementation — returns top N pets by simple matching rules
    scored = @pets.map { |pet| [pet, score_for(pet)] }
    scored.sort_by { |_, s| -s }.first(@limit).map(&:first)
  end

  private

  def score_for(pet)
    score = 0
    # example: increase score if species matches user's preference (if present)
    pref = @user&.preferred_species
    score += 10 if pref.present? && pet.pet_type == pref
    # small boost for recent additions
    score += 1 if pet.created_at > 30.days.ago
    score
  end
end
