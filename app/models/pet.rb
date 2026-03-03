class Pet < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  has_many :requests, dependent: :destroy
  has_one_attached :image
  
  # Interaction associations for recommendation system
  has_many :interactions, dependent: :destroy
  has_many :liking_users, -> { where(interactions: { action: 'like' }) }, through: :interactions, source: :user
  has_many :wishlisting_users, -> { where(interactions: { action: 'wishlist' }) }, through: :interactions, source: :user
  
  # Enums
  enum :pet_type, { dog: 'dog', cat: 'cat', rabbit: 'rabbit', parrot: 'parrot', other: 'other' }
  enum :size, { small: 'small', medium: 'medium', large: 'large' }
  enum :sex, { male: 'male', female: 'female' }
  enum :status, { available: 'available', pending: 'pending', adopted: 'adopted', archived: 'archived' }

 
  ENERGY_LEVELS = %w[low medium high].freeze
  TEMPERAMENTS = %w[friendly shy active calm].freeze
  TRAINABILITY_LEVELS = %w[easy medium hard].freeze
  GROOMING_NEEDS = %w[low medium high].freeze
  EXERCISE_NEEDS = %w[low medium high].freeze

 
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :pet_type, presence: true, inclusion: { in: pet_types.keys }
  validates :breed, presence: true, length: { minimum: 2, maximum: 100 }
  validates :age, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 50 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :health_status, length: { maximum: 200 }, allow_blank: true
  validates :size, presence: true, inclusion: { in: sizes.keys }
  validates :sex, presence: true, inclusion: { in: sexes.keys }
  validates :energy_level, inclusion: { in: ENERGY_LEVELS }, allow_blank: true
  validates :temperament, inclusion: { in: TEMPERAMENTS }, allow_blank: true
  validates :trainability, inclusion: { in: TRAINABILITY_LEVELS }, allow_blank: true
  validates :grooming_needs, inclusion: { in: GROOMING_NEEDS }, allow_blank: true
  validates :exercise_needs, inclusion: { in: EXERCISE_NEEDS }, allow_blank: true
  validate :image_size, if: -> { image.attached? }

  # Callbacks
  after_create :send_pet_added_notification
  after_initialize :set_default_status
  after_update :notify_status_change

  
  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where(available: false) }
  scope :by_species, ->(species) { where(pet_type: species&.downcase) if species.present? }
  scope :by_breed, ->(breed) { where('LOWER(breed) = LOWER(?)', breed) if breed.present? }
  scope :by_size, ->(size) { where(size: size&.downcase) if size.present? }
  scope :by_sex, ->(sex) { where(sex: sex&.downcase) if sex.present? }
  scope :by_age_max, ->(max_age) { where('age <= ?', max_age.to_i) if max_age.present? }
  scope :by_energy_level, ->(level) { where(energy_level: level&.downcase) if level.present? }
  scope :by_temperament, ->(temp) { where(temperament: temp&.downcase) if temp.present? }
  scope :by_trainability, ->(level) { where(trainability: level&.downcase) if level.present? }
  scope :by_grooming_needs, ->(needs) { where(grooming_needs: needs&.downcase) if needs.present? }
  scope :by_exercise_needs, ->(needs) { where(exercise_needs: needs&.downcase) if needs.present? }
  scope :apartment_friendly, -> { where(apartment_friendly: true) }
  scope :kids_friendly, -> { where(kids_friendly: true) }
  scope :affectionate, -> { where(affectionate: true) }
  scope :social_with_other_pets, -> { where(social_with_other_pets: true) }
  scope :social_with_children, -> { where(social_with_children: true) }
  scope :vaccinated, -> { where(vaccinated: true) }
  scope :not_vaccinated, -> { where(vaccinated: false) }
  scope :recent, -> { order(created_at: :desc) }


  def adoption_requests_count
    requests.where(request_type: 'adopt').count
  end

  def donation_requests_count
    requests.where(request_type: 'donate').count
  end

  def pending_requests?
    requests.where(status: 'open').any?
  end

  # Interaction statistics for recommendation visibility
  def likes_count
    interactions.likes.count
  end

  def wishlists_count
    interactions.wishlists.count
  end

  def views_count
    interactions.views.count
  end

  def engagement_score
    interactions.sum(:weight)
  end

  def photo_url
    image.attached? ? Rails.application.routes.url_helpers.url_for(image) : '/images/placeholder-pet.jpg'
  end

  
  def set_default_status
 
    return unless has_attribute?(:status)

    self.status ||= 'available'
  end

  def mark_as_adopted!
    update(status: 'adopted', available: false)
  end

  def mark_as_available!
    update(status: 'available', available: true)
  end

  def notify_status_change
    return unless saved_changes.key?('status')
    previous_status, new_status = saved_changes['status']
    begin
      PetMailer.status_changed(self, previous_status, new_status).deliver_later
    rescue StandardError => e
      Rails.logger.error("Failed to enqueue status change mail for Pet #{id}: #{e.message}")
    end
  end

  def mark_as_adopted
    update(available: false)
  end

  def mark_as_available
    update(available: true)
  end

  private

  def image_size
    return unless image.attached?
    if image.blob.byte_size > 5.megabytes
      errors.add(:image, "should be less than 5MB")
    end
  end

  # Check if image is uploaded (ActiveStorage)
  def image_uploaded?
    image.attached?
  end

  def send_pet_added_notification
 
    AdminMailer.new_pet_added_notification(self).deliver_later
  end
end
