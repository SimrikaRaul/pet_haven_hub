# Interaction Model
# Tracks lightweight user-pet interactions for recommendation algorithms.
# This model stores likes, wishlists, views, and adoption completions
# with weights for collaborative filtering.
#
# Weight scale:
#   1 = view (low engagement)
#   2 = like (medium engagement)
#   3 = wishlist (medium-high engagement)
#   5 = adopt (highest engagement - completed adoption)
#
class Interaction < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :pet

  # Action types and their corresponding weights
  ACTIONS = {
    'view' => 1,
    'like' => 2,
    'wishlist' => 3,
    'adopt' => 5
  }.freeze

  # Validations
  validates :user_id, presence: true
  validates :pet_id, presence: true
  validates :action, presence: true, inclusion: { in: ACTIONS.keys }
  validates :weight, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
  validates :user_id, uniqueness: { 
    scope: [:pet_id, :action], 
    message: "has already performed this action on this pet" 
  }

  # Callbacks
  before_validation :set_weight_from_action, on: :create

  # Scopes
  scope :likes, -> { where(action: 'like') }
  scope :wishlists, -> { where(action: 'wishlist') }
  scope :views, -> { where(action: 'view') }
  scope :adoptions, -> { where(action: 'adopt') }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_pet, ->(pet_id) { where(pet_id: pet_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :high_engagement, -> { where('weight >= ?', 2) } # Excludes views
  scope :for_collaborative_filtering, -> { select(:user_id, :pet_id, :weight) }

  # Class methods for creating specific interaction types
  class << self
    def record_like(user, pet)
      find_or_create_interaction(user, pet, 'like')
    end

    def record_wishlist(user, pet)
      find_or_create_interaction(user, pet, 'wishlist')
    end

    def record_view(user, pet)
      find_or_create_interaction(user, pet, 'view')
    end

    def record_adoption(user, pet)
      find_or_create_interaction(user, pet, 'adopt')
    end

    def remove_like(user, pet)
      remove_interaction(user, pet, 'like')
    end

    def remove_wishlist(user, pet)
      remove_interaction(user, pet, 'wishlist')
    end

    # Build user-pet interaction matrix for collaborative filtering
    # Returns a hash: { user_id => { pet_id => weight, ... }, ... }
    def build_interaction_matrix(min_weight: 1)
      matrix = Hash.new { |h, k| h[k] = {} }
      
      where('weight >= ?', min_weight).find_each do |interaction|
        # Use max weight if user has multiple interactions with same pet
        current = matrix[interaction.user_id][interaction.pet_id] || 0
        matrix[interaction.user_id][interaction.pet_id] = [current, interaction.weight].max
      end
      
      matrix
    end

    # Get aggregated weights per user-pet pair (sum of all interaction types)
    def aggregated_weights
      group(:user_id, :pet_id).sum(:weight)
    end

    private

    def find_or_create_interaction(user, pet, action)
      interaction = find_by(user: user, pet: pet, action: action)
      return interaction if interaction

      create(user: user, pet: pet, action: action)
    end

    def remove_interaction(user, pet, action)
      where(user: user, pet: pet, action: action).destroy_all
    end
  end

  # Instance methods
  def like?
    action == 'like'
  end

  def wishlist?
    action == 'wishlist'
  end

  def view?
    action == 'view'
  end

  def adopt?
    action == 'adopt'
  end

  private

  def set_weight_from_action
    # Always set weight based on action (ignores any provided weight)
    self.weight = ACTIONS[action] if action.present?
  end
end
