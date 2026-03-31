class Request < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :pet
  
  # ActiveStorage
  has_one_attached :citizenship_photo_front
  has_one_attached :citizenship_photo_back

  # Attribute type declarations (required for Rails 8.1 enums)
  attribute :rejection_reason_enum, :string

  # Enums
  enum :status, { open: 'open', pending: 'pending', under_review: 'under_review', approved: 'approved', no_show: 'no_show', rejected: 'rejected', scheduled: 'scheduled', completed: 'completed' }
  enum :request_type, { adopt: 'adopt', donate: 'donate' }
  enum :rejection_reason_enum, {
    already_adopted: 'already_adopted',
    unsuitable_home: 'unsuitable_home',
    incomplete_profile: 'incomplete_profile',
    duplicate_request: 'duplicate_request',
    reserved_for_other: 'reserved_for_other',
    other: 'other'
  }

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
  
  # Adoption request validations - only on create
  validates :citizenship_number, presence: { message: "is required for adoption requests" }, if: :adopt?, on: :create
  validates :citizenship_number, format: { with: /\A\d{6,20}\z/, message: "must contain only numbers and be between 6-20 digits" }, allow_blank: true, on: :create
  validates :citizenship_number, length: { minimum: 6, maximum: 20, message: "must be between 6-20 digits" }, allow_blank: true, on: :create
  
  validates :phone_number, presence: { message: "is required for adoption requests" }, if: :adopt?, on: :create
  validates :phone_number, format: { with: /\A[\d\s\-\+\(\)]+\z/, message: "must be a valid phone number" }, allow_blank: true, on: :create
  validates :phone_number, length: { minimum: 7, maximum: 20, message: "must be between 7-20 characters" }, allow_blank: true, on: :create
  
  validates :address, presence: { message: "is required for adoption requests" }, if: :adopt?, on: :create
  validates :address, length: { minimum: 10, maximum: 500, message: "must be between 10-500 characters" }, allow_blank: true, on: :create
  
  validates :house_type, presence: { message: "is required for adoption requests" }, if: :adopt?, on: :create
  validates :house_type, inclusion: { in: %w[apartment house_with_yard farmhouse condo other], message: "must be a valid house type" }, allow_blank: true, on: :create
  
  validates :reason, presence: { message: "is required for adoption requests" }, if: :adopt?, on: :create
  validates :reason, length: { minimum: 20, maximum: 1000, message: "must be between 20-1000 characters" }, allow_blank: true, on: :create
  
  # Rejection validations
  validates :admin_message, length: { maximum: 2000, message: "must be 2000 characters or less" }, allow_blank: true
  
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
  scope :in_progress, -> { where(status: %w[open pending under_review approved scheduled no_show]) }
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

  def reject!(reason_enum = nil, admin_msg = nil)
    # Free up the adoption slot if one was assigned
    if self.adoption_date.present? && self.approved?
      # This will allow another adoption to take this slot
      # (no explicit free needed since we're just clearing our date)
    end
    
    # Update with rejection details - bypass validations since we're just changing status
    begin
      update_columns(
        status: 'rejected',
        rejection_reason_enum: reason_enum,
        admin_message: admin_msg,
        adoption_date: nil,  # Clear the adoption date when rejecting
        updated_at: Time.current
      )
      self  # Return self to indicate success
    rescue => e
      Rails.logger.error("Error rejecting request #{id}: #{e.message}")
      false  # Return false if there's an error
    end
  end

  def mark_as_completed!
    # Only allowed for approved requests
    return false unless approved? && adopt?
    
    begin
      transaction do
        # Update this request to completed
        update_columns(
          status: 'completed',
          completed_at: Time.current,
          updated_at: Time.current
        )
        
        # Update pet status to adopted
        pet.update(status: :adopted)
        
        # Reject all other pending requests for the same pet
        Request.where(pet_id: pet_id)
               .where.not(id: id)
               .where(status: ['open', 'pending', 'under_review', 'approved'])
               .where(request_type: 'adopt')
               .find_each do |other_request|
          other_request.reject!('already_adopted', 'This pet has been adopted by another user.')
          SendEmailJob.perform_later(
            other_request.user.email,
            "Update on Your Adoption Request for #{other_request.pet.name}",
            "This pet has been adopted by another user. Your request has been automatically rejected."
          )
        end
        
        # Send completion email to the user
        SendEmailJob.perform_later(
          user.email,
          "Congratulations on Your Adoption of #{pet.name}!",
          "Welcome #{pet.name} to your family! Thank you for choosing to adopt from Pet Haven Hub."
        )
      end
      true
    rescue => e
      Rails.logger.error("Error marking request #{id} as completed: #{e.message}")
      false
    end
  end

  def mark_as_no_show!
    # Only allowed for approved requests
    return false unless approved? && adopt?
    
    begin
      update_columns(
        status: 'no_show',
        updated_at: Time.current
      )
      
      # Send no show email to the user
      SendEmailJob.perform_later(
        user.email,
        "You Did Not Show for Your Adoption Appointment",
        "You did not show for your scheduled adoption appointment for #{pet.name}. Please contact us to reschedule or discuss what happened."
      )
      true
    rescue => e
      Rails.logger.error("Error marking request #{id} as no show: #{e.message}")
      false
    end
  end

  def reschedule!(new_adoption_date, admin_note = nil)
    # Only allowed for no_show requests
    return false unless no_show? && adopt?
    
    # Validate new date
    return false if new_adoption_date.blank? || new_adoption_date <= Date.today
    
    # Check slot availability
    unless self.class.slots_available_for_date?(new_adoption_date)
      return false
    end
    
    # Check if max reschedules exceeded
    if reschedule_count >= 2
      # Automatically reject if exceeded
      reject!('duplicate_request', 'Maximum reschedule attempts reached. Your request has been rejected.')
      SendEmailJob.perform_later(
        user.email,
        "Your Adoption Request for #{pet.name} Has Been Rejected",
        "You have reached the maximum number of reschedule attempts. Your request has been rejected. Please contact us if you would like to discuss this."
      )
      return false
    end
    
    begin
      update_columns(
        adoption_date: new_adoption_date,
        status: 'approved',
        reschedule_count: reschedule_count + 1,
        admin_note: admin_note.present? ? admin_note : self.admin_note,
        updated_at: Time.current
      )
      
      # Send reschedule email
      SendEmailJob.perform_later(
        user.email,
        "Your Adoption Appointment Has Been Rescheduled for #{pet.name}",
        "Your adoption appointment for #{pet.name} has been rescheduled. Please check your account for the new date and time."
      )
      true
    rescue => e
      Rails.logger.error("Error rescheduling request #{id}: #{e.message}")
      false
    end
  end

  def can_be_approved?
    (open? || pending?) && pet.available?
  end

  def can_be_rejected?
    open? || pending? || scheduled?
  end
  
  def can_be_completed?
    approved? && adoption_date.present? && adoption_date <= Date.today && adopt?
  end
  
  def can_be_marked_no_show?
    approved? && adoption_date.present? && adoption_date <= Date.today && adopt?
  end
  
  def can_be_rescheduled?
    no_show? && adopt? && reschedule_count < 2
  end

  def in_progress?
    %w[open pending under_review approved scheduled no_show].include?(status)
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
    
    # Validate front photo
    if citizenship_photo_front.attached?
      if citizenship_photo_front.blob.byte_size > 5.megabytes
        errors.add(:citizenship_photo_front, 'must be less than 5MB')
      end
      
      unless citizenship_photo_front.content_type.in?(%w[image/jpeg image/jpg image/png image/gif])
        errors.add(:citizenship_photo_front, 'must be a JPEG, PNG, or GIF image')
      end
    else
      errors.add(:citizenship_photo_front, 'is required for adoption requests')
    end
    
    # Validate back photo
    if citizenship_photo_back.attached?
      if citizenship_photo_back.blob.byte_size > 5.megabytes
        errors.add(:citizenship_photo_back, 'must be less than 5MB')
      end
      
      unless citizenship_photo_back.content_type.in?(%w[image/jpeg image/jpg image/png image/gif])
        errors.add(:citizenship_photo_back, 'must be a JPEG, PNG, or GIF image')
      end
    else
      errors.add(:citizenship_photo_back, 'is required for adoption requests')
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
    SendEmailJob.perform_later(
      user.email,
      "Your Adoption Request for #{pet.name} Has Been Received",
      "Thank you for your interest in adopting #{pet.name}. We have received your request and will review it shortly."
    )
  end

  def handle_status_change
    case status
    when 'completed'
      nil
    when 'scheduled'
      SendEmailJob.perform_later(
        user.email,
        "Your Adoption is Scheduled for #{pet.name}",
        "Your adoption appointment for #{pet.name} has been scheduled. Please check your account for details."
      )
    end
  end

  def send_approval_notification
    SendEmailJob.perform_later(
      user.email,
      "Your Adoption Request for #{pet.name} Has Been Approved!",
      "Congratulations! Your adoption request for #{pet.name} has been approved. Please log in to your account for next steps."
    )
  end

  def send_rejection_notification
    SendEmailJob.perform_later(
      user.email,
      "Update on Your Adoption Request for #{pet.name}",
      "Unfortunately, your adoption request for #{pet.name} was not approved at this time. You are welcome to submit another request in the future."
    )
  end

  def send_completion_notification
    SendEmailJob.perform_later(
      user.email,
      "Congratulations on Your Adoption of #{pet.name}!",
      "Welcome #{pet.name} to your family! Thank you for choosing to adopt from Pet Haven Hub."
    )
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
