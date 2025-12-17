# User Preferences Model
# Stores user-entered preferences for pet recommendations
# This is SEPARATE from pet attributes and should never be mixed
class UserPreference < ApplicationRecord
  # Associations
  belongs_to :user

  # Constants for valid preference values
  ENERGY_LEVELS = %w[low medium high].freeze
  TEMPERAMENTS = %w[calm friendly playful].freeze
  GROOMING_NEEDS = %w[low medium high].freeze
  EXERCISE_NEEDS = %w[low medium high].freeze

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :preferred_energy_level, inclusion: { in: ENERGY_LEVELS, allow_blank: true }
  validates :preferred_temperament, inclusion: { in: TEMPERAMENTS, allow_blank: true }
  validates :preferred_grooming_needs, inclusion: { in: GROOMING_NEEDS, allow_blank: true }
  validates :preferred_exercise_needs, inclusion: { in: EXERCISE_NEEDS, allow_blank: true }

  # Convert categorical values to numeric scores for comparison
  # low = 1, medium = 2, high = 3
  def energy_level_score
    score_from_level(preferred_energy_level)
  end

  def grooming_needs_score
    score_from_level(preferred_grooming_needs)
  end

  def exercise_needs_score
    score_from_level(preferred_exercise_needs)
  end

  private

  def score_from_level(level)
    case level
    when 'low' then 1
    when 'medium' then 2
    when 'high' then 3
    else 0
    end
  end
end
