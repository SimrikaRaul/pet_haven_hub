class Request < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :pet

  # Enums
  enum status: { open: 'open', approved: 'approved', rejected: 'rejected', scheduled: 'scheduled', completed: 'completed' }
  enum request_type: { adopt: 'adopt', donate: 'donate' }

  # Validations
  validates :user_id, :pet_id, :request_type, :status, presence: true
  validates :request_type, inclusion: { in: request_types.keys }
  validates :status, inclusion: { in: statuses.keys }
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validates :route_distance, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :scheduled_date, presence: true, if: proc { scheduled? }

  # Callbacks
  after_create :send_request_confirmation
  after_update :handle_status_change, if: :saved_change_to_status?
  after_update :schedule_route_calculation, if: proc { approved? && route.blank? }

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

  def route_distance_in_km
    "#{route_distance.round(2)} km" if route_distance.present?
  end

  def days_pending
    ((Time.current - created_at) / 1.day).round
  end

  private

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

  def schedule_route_calculation
    RouteCalculationJob.perform_later(id) if approved?
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
