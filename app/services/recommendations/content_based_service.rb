# Content-based recommendation service
# Builds simple feature vectors for pets and computes cosine similarity
require_relative '../application_service'

class Recommendations::ContentBasedService < ApplicationService
  def initialize(user:, pets: nil, pet: nil, limit: 10)
    @user = user
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
    scored = @pets.map { |pet| [pet, score_for(pet)] }
    scored.sort_by { |_, s| -s }.first(@limit).map(&:first)
  end

  private

  def score_for(pet)
    score = 0
    pref = @user&.preferred_species
    score += 10 if pref.present? && pet.pet_type == pref
    score += 1 if pet.created_at > 30.days.ago
    score
  end
end
