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
  MAX_ADOPTION_SLOTS_PER_DATE = 5

  # Validations
  validates :user_id, :pet_id, :request_type, :status, presence: true
  validates :request_type, inclusion: { in: request_types.keys }
  validates :status, inclusion: { in: statuses.keys }
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validates :scheduled_date, presence: true, if: proc { scheduled? }
  
  # Adoption date and admin note validations
  validates :adoption_date, presence: true, if: proc { approved? && adopt? }
  validates :adoption_date, inclusion: { in: proc { [Date.tomorrow..99.years.from_now] }, message: "must be a future date" }, if: proc { adoption_date.present? && approved? && adopt? }
  validates :admin_note, length: { maximum: 2000 }, allow_blank: true
  validate :adoption_date_slot_availability, if: proc { adoption_date.present? && approved? && adopt? }
  
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
  scope :pending_decision, -> { where(status: %w[open pending under_review]) }
  scope :for_adoption, -> { where(request_type: 'adopt') }
  scope :for_donation, -> { where(request_type: 'donate') }
  scope :recent, -> { order(created_at: :desc) }
  scope :in_progress, -> { where(status: %w[open pending under_review approved scheduled]) }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_pet, ->(pet_id) { where(pet_id: pet_id) if pet_id.present? }
  scope :by_date_range, ->(start_date, end_date) do
    where('created_at >= ? AND created_at <= ?', start_date, end_date) if start_date.present? && end_date.present?
  end
  scope :by_adoption_date, ->(date) { where(adoption_date: date) if date.present? }
  scope :approved_for_adoption, ->(date) { approved.for_adoption.by_adoption_date(date) }
  scope :available_for_date, ->(date) do
    where(adoption_date: date, status: 'approved', request_type: 'adopt')
  end


  def approve!
    update(status: 'approved')
  end

  def reject!(reason = nil)
    update(status: 'rejected', rejection_reason: reason)
  end

  def mark_as_completed
    update(status: 'completed', completed_at: Time.current)
    AdoptionMailer.notify_user(self).deliver_later
  end

  def can_be_approved?
    (open? || pending?) && pet.available?
  end

  def can_be_rejected?
    open? || pending? || scheduled?
  end

  def in_progress?
    %w[open pending under_review approved scheduled].include?(status)
  end

  def days_pending
    ((Time.current - created_at) / 1.day).round
  end

  # Check if a given date has available slots for approval
  def self.slots_available_for_date?(date)
    return false if date.blank? || date <= Date.today
    
    approved_count = available_for_date(date).count
    approved_count < MAX_ADOPTION_SLOTS_PER_DATE
  end

  # Get the count of approved adoptions for a given date
  def self.approved_count_for_date(date)
    return 0 if date.blank?
    
    available_for_date(date).count
  end

  # Get available dates for adoption scheduling (next 90 days with available slots)
  def self.available_dates_for_scheduling
    available_dates = []
    start_date = Date.tomorrow
    end_date = 90.days.from_now.to_date
    
    (start_date..end_date).each do |date|
      available_dates << date if slots_available_for_date?(date)
    end
    
    available_dates
  end

  # Get a list of fully booked dates (for disabling in date picker)
  def self.fully_booked_dates(start_date = Date.tomorrow, end_date = 90.days.from_now.to_date)
    booked_dates = []
    
    (start_date..end_date).each do |date|
      booked_dates << date unless slots_available_for_date?(date)
    end
    
    booked_dates
  end

  # Check if this request's adoption date has available slots (useful after validation)
  def adoption_date_has_slots?
    return true if adoption_date.blank?
    
    # When updating an existing approved request, exclude the current record from count
    count = self.class.available_for_date(adoption_date).where.not(id: id).count
    count < self.class::MAX_ADOPTION_SLOTS_PER_DATE
  end

  private

  def adoption_date_slot_availability
    return if adoption_date.blank?
    
    # Check if this is a new adoption request or updating adoption_date
    unless adoption_date_has_slots?
      errors.add(:adoption_date, "is fully booked. Maximum #{self.class::MAX_ADOPTION_SLOTS_PER_DATE} adoptions per day allowed.")
    end
  end

  def citizenship_photo_validation
    return unless adopt?
    
    if citizenship_photo.attached?
      if citizenship_photo.blob.byte_size > 5.megabytes
        errors.add(:citizenship_photo, 'must be less than 5MB')
      end
      
      unless citizenship_photo.content_type.in?(%w[image/jpeg image/jpg image/png image/gif])
        errors.add(:citizenship_photo, 'must be a JPEG, PNG, or GIF image')
      end
    else
      errors.add(:citizenship_photo, 'is required for adoption requests')
    end
  end

  def not_duplicate_request
    return unless user_id.present? && pet_id.present?

    # Only block if there's an existing request that is still pending decision
    # Allow re-request if previous request was rejected or completed
    existing_pending = Request.pending_decision.where(user_id: user_id, pet_id: pet_id).exists?

    if existing_pending
      errors.add(:base, 'You have already submitted a request for this pet.')
    end
  end

  def within_active_request_limit
    return unless user_id.present?

    # Count requests that are still pending decision (open, pending, under_review)
    pending_count = Request.pending_decision.where(user_id: user_id).count

    if pending_count >= MAX_ACTIVE_REQUESTS
      errors.add(:base, "You can only request up to #{MAX_ACTIVE_REQUESTS} pets at a time. Please wait until a request is approved or rejected.")
    end
  end

  def send_request_confirmation
    RequestMailer.request_confirmation(self).deliver_later
  end

  def handle_status_change
    case status
    when 'completed'
      nil
    when 'scheduled'
      AdoptionMailer.notify_user(self).deliver_later
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


  def became_completed_adoption?
    saved_change_to_status? && 
    status == 'completed' && 
    adopt?
  end


  def record_adoption_interaction
    Interaction.record_adoption(user, pet)
  end
end
