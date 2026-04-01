class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable

  has_many :pets, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :adoptions, class_name: 'Request', foreign_key: 'user_id', dependent: :destroy
  has_one :user_preference, dependent: :destroy
  
  # Interaction associations for recommendation system
  has_many :interactions, dependent: :destroy
  has_many :liked_pets, -> { where(interactions: { action: 'like' }) }, through: :interactions, source: :pet
  has_many :wishlisted_pets, -> { where(interactions: { action: 'wishlist' }) }, through: :interactions, source: :pet
  
  enum :role, { user: 'user', admin: 'admin', shelter_manager: 'shelter_manager' }, suffix: true

  after_initialize :set_default_role, if: :new_record?
  after_create :send_welcome_email

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, allow_blank: true,
                    format: { with: /\A[+]?[0-9]{10,15}\z/, message: 'must be a valid phone number' }
  validates :address, length: { maximum: 500 }, allow_blank: true
  validates :city, length: { maximum: 100 }, allow_blank: true

  # Active users are those who have listed pets or made requests
  scope :active_users, -> { where('EXISTS(SELECT 1 FROM pets WHERE pets.user_id = users.id) OR EXISTS(SELECT 1 FROM requests WHERE requests.user_id = users.id)') }
  scope :recent, -> { order(created_at: :desc) }
  scope :admins, -> { where(role: 'admin') }
  scope :with_adoption_history, -> { joins(:requests).distinct }

  def admin?
    role == 'admin' || email == ENV['ADMIN_EMAIL']
  end

  def shelter_manager?
    role == 'shelter_manager'
  end

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

  # Interaction helper methods
  def liked?(pet)
    interactions.exists?(pet: pet, action: 'like')
  end

  def wishlisted?(pet)
    interactions.exists?(pet: pet, action: 'wishlist')
  end

  def like!(pet)
    Interaction.record_like(self, pet)
  end

  def unlike!(pet)
    Interaction.remove_like(self, pet)
  end

  def add_to_wishlist!(pet)
    Interaction.record_wishlist(self, pet)
  end

  def remove_from_wishlist!(pet)
    Interaction.remove_wishlist(self, pet)
  end

  def toggle_like!(pet)
    liked?(pet) ? unlike!(pet) : like!(pet)
  end

  def toggle_wishlist!(pet)
    wishlisted?(pet) ? remove_from_wishlist!(pet) : add_to_wishlist!(pet)
  end

  private

  def set_default_role
    self.role ||= 'user'
  end

  def send_welcome_email
    PetHavenMailer.welcome_email(self)
  end
end 
