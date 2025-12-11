class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  
  has_many :pets, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :adoptions, class_name: 'Request', foreign_key: 'user_id', dependent: :destroy
  
  # Enums (store strings in DB). Keep _suffix if other code relies on it,
  # but we'll provide explicit predicate helpers below for compatibility.
  enum role: { user: 'user', admin: 'admin', shelter_manager: 'shelter_manager' }, _suffix: true
# Set a sensible default role for new records (not for persisted rows)
  after_initialize :set_default_role, if: :new_record?

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, allow_blank: true,
                    format: { with: /\A[+]?[0-9]{10,15}\z/, message: 'must be a valid phone number' }
  validates :address, length: { maximum: 500 }, allow_blank: true
  validates :city, length: { maximum: 100 }, allow_blank: true

  # NOTE: DO NOT validate the old boolean `admin` column here — we rely on the `role` enum.
  # If the DB still has an `admin:boolean` column it will be ignored by the model logic.
  #
  # If you have code that still writes to the boolean `admin` column, remove it
  # or migrate existing boolean flags into the `role` column and then drop the boolean.

  # Scopes
  scope :active_users, -> { where("confirmed_at IS NOT NULL OR sign_in_count > 0") }
  scope :recent, -> { order(created_at: :desc) }
  scope :admins, -> { where(role: 'admin') }
  scope :with_adoption_history, -> { joins(:requests).distinct }
# Explicit role predicate helpers (keeps calls like `current_user.admin?` working)
  def admin?
    # Check if user has admin role OR matches static admin email (if configured)
    role == 'admin' || email == ENV['ADMIN_EMAIL']
  end

  def shelter_manager?
    role == 'shelter_manager'
  end

  # Useful display and counters
  def full_name
    name.presence || email.to_s.split('@').first
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

private


  def set_default_role
    self.role ||= 'user'
  end
end
