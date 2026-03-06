# User Preferences Model
# Stores user-entered preferences for pet recommendations
# This is SEPARATE from pet attributes and should never be mixed
class UserPreference < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums for compatibility scoring fields
  enum :living_space, { apartment: 0, house: 1, farm: 2 }, prefix: true
  enum :experience_level, { beginner: 0, intermediate: 1, expert: 2 }, prefix: true
  enum :activity_level, { low: 0, medium: 1, high: 2 }, prefix: true

  # Constants for valid preference values
  ENERGY_LEVELS = %w[low medium high].freeze
  TEMPERAMENTS = %w[calm friendly playful].freeze
  GROOMING_NEEDS = %w[low medium high].freeze
  EXERCISE_NEEDS = %w[low medium high].freeze
  LIVING_SPACES = %w[apartment house farm].freeze
  EXPERIENCE_LEVELS = %w[beginner intermediate expert].freeze
  ACTIVITY_LEVELS = %w[low medium high].freeze

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :preferred_energy_level, inclusion: { in: ENERGY_LEVELS, allow_blank: true }
  validates :preferred_temperament, inclusion: { in: TEMPERAMENTS, allow_blank: true }
  validates :preferred_grooming_needs, inclusion: { in: GROOMING_NEEDS, allow_blank: true }
  validates :preferred_exercise_needs, inclusion: { in: EXERCISE_NEEDS, allow_blank: true }

  # Compatibility scoring field validations (enums handle value constraints automatically)
  validates :living_space, inclusion: { in: living_spaces.keys }, allow_nil: true
  validates :experience_level, inclusion: { in: experience_levels.keys }, allow_nil: true
  validates :activity_level, inclusion: { in: activity_levels.keys }, allow_nil: true

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

  # Numeric scores for compatibility calculation
  def living_space_score
    living_space ? self.class.living_spaces[living_space] + 1 : 0
  end

  def experience_level_score
    experience_level ? self.class.experience_levels[experience_level] + 1 : 0
  end

  def activity_level_score
    activity_level ? self.class.activity_levels[activity_level] + 1 : 0
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
