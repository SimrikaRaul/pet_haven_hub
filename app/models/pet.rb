class Pet < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  has_many :requests, dependent: :destroy
  mount_uploader :image, ImageUploader
  # Enums
  enum pet_type: { dog: 'dog', cat: 'cat', rabbit: 'rabbit', bird: 'bird', other: 'other' }
  enum size: { small: 'small', medium: 'medium', large: 'large' }
  enum sex: { male: 'male', female: 'female' }
  enum status: { available: 'available', pending: 'pending', adopted: 'adopted', archived: 'archived' }

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :pet_type, presence: true, inclusion: { in: pet_types.keys }
  validates :breed, presence: true, length: { minimum: 2, maximum: 100 }
  validates :age, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 50 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :health_status, length: { maximum: 200 }, allow_blank: true
  validates :size, presence: true, inclusion: { in: sizes.keys }
  validates :sex, presence: true, inclusion: { in: sexes.keys }
  validates :latitude, numericality: true, allow_blank: true
  validates :longitude, numericality: true, allow_blank: true
  validate :image_size, if: -> { image.file.present? }

  # Callbacks
  before_save :geocode_location_if_needed
  after_create :send_pet_added_notification
  after_initialize :set_default_status
  after_update :notify_status_change

  # Scopes
  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where(available: false) }
  scope :by_species, ->(species) { where(pet_type: species) if species.present? }
  scope :by_breed, ->(breed) { where(breed: breed) if breed.present? }
  scope :by_size, ->(size) { where(size: size) if size.present? }
  scope :by_sex, ->(sex) { where(sex: sex) if sex.present? }
  scope :by_age_max, ->(max_age) { where('age <= ?', max_age.to_i) if max_age.present? }
  scope :vaccinated, -> { where(vaccinated: true) }
  scope :not_vaccinated, -> { where(vaccinated: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :near_location, ->(lat, lon, radius = 50) do
    if lat.present? && lon.present?
      where("(6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) < ?", 
            lat.to_f, lon.to_f, lat.to_f, radius.to_i)
    end
  end

  # Instance Methods
  def location_name
    "#{city}, #{country}" if city.present? && country.present?
  end

  def adoption_requests_count
    requests.where(request_type: 'adopt').count
  end

  def donation_requests_count
    requests.where(request_type: 'donate').count
  end

  def pending_requests?
    requests.where(status: 'open').any?
  end

  def photo_url
    image.file.present? ? image.url : '/images/placeholder-pet.jpg'
  end

  # Status helpers
  def set_default_status
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

  def geocode_location_if_needed
    return unless (latitude.blank? || longitude.blank?) && city.present?
    geocode_location
  end

  def geocode_location
    begin
      result = Geocoder.search("#{city}, #{country}").first
      if result
        self.latitude = result.latitude
        self.longitude = result.longitude
      end
    rescue StandardError => e
      Rails.logger.error("Geocoding error for pet #{id}: #{e.message}")
    end
  end

  def image_size
    return unless image.file.present?
    if image.file.size > 5.megabytes
      errors.add(:image, "should be less than 5MB")
    end
  end

  # Returns true when an image file has been uploaded
  def image_uploaded?
    image.file.present?
  end

  def send_pet_added_notification
    # Notify admins about new pet listing
    AdminMailer.new_pet_added_notification(self).deliver_later
  end
end
