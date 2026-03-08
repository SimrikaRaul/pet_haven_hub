class Request < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :pet
  
  # ActiveStorage
  has_one_attached :citizenship_photo

  # Enums
  enum :status, { open: 'open', pending: 'pending', under_review: 'under_review', approved: 'approved', rejected: 'rejected', scheduled: 'scheduled', completed: 'completed' }
  enum :request_type, { adopt: 'adopt', donate: 'donate' }

  # Adoption request limit constants
  MAX_ACTIVE_REQUESTS = 3

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
  
  # Adoption request limit validations
  validate :not_duplicate_request, on: :create
  validate :within_active_request_limit, on: :create

  # Citizenship photo validation
  validate :citizenship_photo_validation, if: :adopt?

  # Callbacks
  after_create :send_request_confirmation
  after_update :handle_status_change, if: :saved_change_to_status?
  after_update :record_adoption_interaction, if: :became_completed_adoption?


  # Scopes
  scope :open, -> { where(status: 'open') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :completed, -> { where(status: 'completed') }
  scope :active, -> { where(status: %w[pending under_review]) }
  scope :for_adoption, -> { where(request_type: 'adopt') }
  scope :for_donation, -> { where(request_type: 'donate') }
  scope :recent, -> { order(created_at: :desc) }
  scope :in_progress, -> { where(status: %w[open pending under_review approved scheduled]) }
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

  def in_progress?
    %w[open pending under_review approved scheduled].include?(status)
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

  def not_duplicate_request
    return unless user_id.present? && pet_id.present?

    if Request.where(user_id: user_id, pet_id: pet_id).exists?
      errors.add(:base, 'You have already requested adoption for this pet.')
    end
  end

  def within_active_request_limit
    return unless user_id.present?

    active_count = Request.active.where(user_id: user_id).count
    if active_count >= MAX_ACTIVE_REQUESTS
      errors.add(:base, 'You already have 3 active adoption requests. Please wait until one request is approved or rejected.')
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

  # Check if the request just became a completed adoption
  def became_completed_adoption?
    saved_change_to_status? && 
    status == 'completed' && 
    adopt?
  end

  # Record a strong interaction (weight=5) when adoption is completed
  def record_adoption_interaction
    Interaction.record_adoption(user, pet)
  end
end
