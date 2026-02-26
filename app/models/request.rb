class Request < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :pet
  
  # ActiveStorage
  has_one_attached :citizenship_photo

  # Enums
  enum :status, { open: 'open', approved: 'approved', rejected: 'rejected', scheduled: 'scheduled', completed: 'completed' }
  enum :request_type, { adopt: 'adopt', donate: 'donate' }

  # Validations
  validates :user_id, :pet_id, :request_type, :status, presence: true
  validates :request_type, inclusion: { in: request_types.keys }
  validates :status, inclusion: { in: statuses.keys }
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validates :scheduled_date, presence: true, if: proc { scheduled? }
  
  # Adoption request validations
  validates :citizenship_number, presence: { message: "is required for adoption requests" }, if: :adopt?
  validates :citizenship_number, format: { with: /\A\d{6,20}\z/, message: "must contain only numbers and be between 6-20 digits" }, allow_blank: true
  validates :citizenship_number, length: { minimum: 6, maximum: 20, message: "must be between 6-20 digits" }, allow_blank: true
  
  validates :phone_number, presence: { message: "is required for adoption requests" }, if: :adopt?
  validates :phone_number, format: { with: /\A[\d\s\-\+\(\)]+\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :phone_number, length: { minimum: 7, maximum: 20, message: "must be between 7-20 characters" }, allow_blank: true
  
  validates :address, presence: { message: "is required for adoption requests" }, if: :adopt?
  validates :address, length: { minimum: 10, maximum: 500, message: "must be between 10-500 characters" }, allow_blank: true
  
  validates :house_type, presence: { message: "is required for adoption requests" }, if: :adopt?
  validates :house_type, inclusion: { in: %w[apartment house_with_yard farmhouse condo other], message: "must be a valid house type" }, allow_blank: true
  
  validates :reason, presence: { message: "is required for adoption requests" }, if: :adopt?
  validates :reason, length: { minimum: 20, maximum: 1000, message: "must be between 20-1000 characters" }, allow_blank: true
  
  # Citizenship photo validation
  validate :citizenship_photo_validation, if: :adopt?

  # Callbacks
  after_create :send_request_confirmation
  after_update :handle_status_change, if: :saved_change_to_status?


  # Scopes
  scope :open, -> { where(status: 'open') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :completed, -> { where(status: 'completed') }
  scope :for_adoption, -> { where(request_type: 'adopt') }
  scope :for_donation, -> { where(request_type: 'donate') }
  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: %w[open approved scheduled]) }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_pet, ->(pet_id) { where(pet_id: pet_id) if pet_id.present? }
  scope :by_date_range, ->(start_date, end_date) do
    where('created_at >= ? AND created_at <= ?', start_date, end_date) if start_date.present? && end_date.present?
  end

  # Instance Methods
  def approve!
    update(status: 'approved')
    send_approval_notification
  end

  def reject!(reason = nil)
    update(status: 'rejected', rejection_reason: reason)
    send_rejection_notification
  end

  def mark_as_completed
    update(status: 'completed', completed_at: Time.current)
    send_completion_notification
  end

  def can_be_approved?
    open? && pet.available?
  end

  def can_be_rejected?
    open? || scheduled?
  end

  def pending?
    %w[open approved scheduled].include?(status)
  end

  def days_pending
    ((Time.current - created_at) / 1.day).round
  end

  private

  def citizenship_photo_validation
    return unless adopt?
    
    if citizenship_photo.attached?
      # Check file size (max 5MB)
      if citizenship_photo.blob.byte_size > 5.megabytes
        errors.add(:citizenship_photo, 'must be less than 5MB')
      end
      
      # Check content type
      unless citizenship_photo.content_type.in?(%w[image/jpeg image/jpg image/png image/gif])
        errors.add(:citizenship_photo, 'must be a JPEG, PNG, or GIF image')
      end
    else
      errors.add(:citizenship_photo, 'is required for adoption requests')
    end
  end

  def send_request_confirmation
    RequestMailer.request_confirmation(self).deliver_later
  end

  def handle_status_change
    case status
    when 'approved'
      send_approval_notification
    when 'rejected'
      send_rejection_notification
    when 'completed'
      send_completion_notification
    end
  end

  def send_approval_notification
    RequestMailer.request_approved(self).deliver_later
  end

  def send_rejection_notification
    RequestMailer.request_rejected(self).deliver_later
  end

  def send_completion_notification
    RequestMailer.request_completed(self).deliver_later
  end
end
