class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :pets, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :adoptions, class_name: 'Request', foreign_key: 'user_id', dependent: :destroy

  # Enums
  enum role: { user: 'user', admin: 'admin', shelter_manager: 'shelter_manager' }, _suffix: true

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, allow_blank: true, format: { with: /\A[+]?[0-9]{10,15}\z/, message: 'must be a valid phone number' }
  validates :address, length: { maximum: 500 }, allow_blank: true
  validates :city, length: { maximum: 100 }, allow_blank: true

  # Scopes
  scope :active_users, -> { where("confirmed_at IS NOT NULL OR sign_in_count > 0") }
  scope :recent, -> { order(created_at: :desc) }
  scope :admins, -> { where(role: 'admin') }
  scope :with_adoption_history, -> { joins(:requests).distinct }

  # Instance Methods
  def admin?
    role == 'admin'
  end

  def shelter_manager?
    role == 'shelter_manager'
  end

  def full_name
    name || email.split('@').first
  end

  def adoption_count
    requests.where(status: 'completed').count
  end

  def pending_requests_count
    requests.where(status: 'open').count
  end

  def approved_requests_count
    requests.where(status: 'approved').count
  end

  def location_coordinates
    [latitude, longitude] if latitude.present? && longitude.present?
  end

  def geocode_location
    return unless address.present? && city.present?
    
    begin
      result = Geocoder.search("#{address}, #{city}").first
      if result
        self.latitude = result.latitude
        self.longitude = result.longitude
      end
    rescue StandardError => e
      Rails.logger.error("Geocoding error for user #{id}: #{e.message}")
    end
  end
end
