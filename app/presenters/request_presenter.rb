class RequestPresenter
  delegate :id, :status, :request_type, :notes, :created_at, :updated_at, 
           :route, :route_distance, :scheduled_date, :completed_at, to: :request

  def initialize(request)
    @request = request
  end

  def request
    @request
  end

  def status_badge_class
    case status.to_s
    when 'open'
      'bg-yellow-500'
    when 'approved'
      'bg-green-500'
    when 'rejected'
      'bg-red-500'
    when 'scheduled'
      'bg-blue-500'
    when 'completed'
      'bg-gray-600'
    else
      'bg-gray-400'
    end
  end

  def status_label
    status.to_s.titleize
  end

  def request_type_label
    case request_type.to_s
    when 'adopt'
      '🏠 Adoption'
    when 'donate'
      '💝 Donation'
    else
      request_type&.titleize
    end
  end

  def pet_info
    "#{pet.name} (#{pet.pet_type&.titleize})"
  end

  def pet
    request.pet
  end

  def user
    request.user
  end

  def user_info
    user.full_name
  end

  def days_pending
    ((Time.current - created_at) / 1.day).round
  end

  def pending_since
    "Pending for #{days_pending} day#{'s' if days_pending != 1}"
  end

  def route_distance_display
    if route_distance.present?
      "#{route_distance.round(2)} km"
    else
      'N/A'
    end
  end

  def scheduled_date_display
    scheduled_date&.strftime('%B %d, %Y at %I:%M %p') || 'Not scheduled'
  end

  def completed_date_display
    completed_at&.strftime('%B %d, %Y at %I:%M %p') || 'Not completed'
  end

  def action_buttons
    case status.to_s
    when 'open'
      ['approve', 'reject']
    when 'approved'
      ['view_route', 'mark_completed']
    when 'scheduled'
      ['mark_completed', 'cancel']
    when 'rejected'
      []
    when 'completed'
      ['view_details']
    else
      []
    end
  end

  def can_be_approved?
    request.can_be_approved?
  end

  def can_be_rejected?
    request.can_be_rejected?
  end

  def to_json(options = {})
    {
      id: request.id,
      status: status,
      request_type: request_type,
      pet: pet_info,
      user: user_info,
      created_at: created_at.strftime('%B %d, %Y'),
      days_pending: days_pending,
      route_distance: route_distance_display
    }
  end
end
