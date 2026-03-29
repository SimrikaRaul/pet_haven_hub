# Helper module for adoption scheduling features
module AdoptionSchedulingHelper
  # Adoption center information
  ADOPTION_CENTER_NAME = "Pet Haven Hub"
  ADOPTION_CENTER_LOCATION = "Panauti, Kathmandu, Nepal"

  # Get adoption center name
  def adoption_center_name
    ADOPTION_CENTER_NAME
  end

  # Get adoption center location
  def adoption_center_location
    ADOPTION_CENTER_LOCATION
  end

  # Format adoption date for display
  def format_adoption_date(date)
    return '—' if date.blank?
    date.strftime('%A, %B %-d, %Y')
  end

  # Check if a date is fully booked
  def fully_booked?(date)
    !Request.slots_available_for_date?(date)
  end

  # Get the count of approved adoptions for a date
  def adoption_count_for_date(date)
    Request.approved_count_for_date(date)
  end

  # Get remaining slots for a date
  def remaining_slots_for_date(date)
    Request::MAX_ADOPTION_SLOTS_PER_DATE - adoption_count_for_date(date)
  end

  # Display slot availability status
  def slot_availability_badge(date)
    count = adoption_count_for_date(date)
    max = Request::MAX_ADOPTION_SLOTS_PER_DATE
    
    tag.div(class: "slot-badge #{count >= max ? 'fully-booked' : 'available'}") do
      if count >= max
        "🔴 Fully Booked"
      else
        "🟢 #{max - count} slots available"
      end
    end
  end

  # Get list of available dates for scheduling with count
  def available_dates_with_count(start_date = Date.tomorrow, end_date = 90.days.from_now.to_date)
    available_dates = []
    
    (start_date..end_date).each do |date|
      if Request.slots_available_for_date?(date)
        remaining = remaining_slots_for_date(date)
        available_dates << { date: date, remaining_slots: remaining }
      end
    end
    
    available_dates
  end

  # Check if user has an approved adoption with scheduled date
  def has_scheduled_adoption?(user)
    user.requests.where(status: 'approved', request_type: 'adopt')
        .where('adoption_date IS NOT NULL').exists?
  end

  # Get user's next scheduled adoption
  def next_scheduled_adoption(user)
    user.requests
      .where(status: 'approved', request_type: 'adopt')
      .where('adoption_date IS NOT NULL')
      .order(adoption_date: :asc)
      .first
  end

  # Display admin note in a formatted way
  def display_admin_note(note)
    return content_tag(:em, 'No special instructions') if note.blank?
    
    simple_format(h(note), {}, sanitize: false)
  end

  # Get color/style for adoption date based on proximity
  def adoption_date_urgency_class(date)
    return 'urgency-critical' if date == Date.tomorrow
    return 'urgency-high' if date <= 3.days.from_now
    return 'urgency-medium' if date <= 7.days.from_now
    'urgency-low'
  end

  # Check if date is within the next X days
  def date_is_soon?(date, days = 7)
    date.present? && (Date.today..days.days.from_now.to_date).include?(date)
  end
end
