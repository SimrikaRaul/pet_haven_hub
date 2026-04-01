module PetsHelper
  # Check if a pet is approved for the current user
  def pet_approved_for_current_user?(pet)
    return false unless user_signed_in?
    pet.approved_for_user?(current_user)
  end

  # Check if a pet has a pending adoption request from the current user
  def pet_pending_for_current_user?(pet)
    return false unless user_signed_in?
    pet.pending_for_user?(current_user)
  end

  # Check if a pet has been requested or approved by the current user
  def pet_requested_or_approved_by_current_user?(pet)
    return false unless user_signed_in?
    pet.already_requested_or_approved?(current_user)
  end

  # Get adoption status badge for the current user and pet
  def adoption_status_badge(pet)
    return nil unless user_signed_in?

    if pet.approved_for_user?(current_user)
      {
        status: :approved,
        icon: '✅',
        text: 'Approved for You',
        css_class: 'badge-adoption-approved'
      }
    elsif pet.pending_for_user?(current_user)
      {
        status: :pending,
        icon: '⏳',
        text: 'Your Request Pending',
        css_class: 'badge-adoption-pending'
      }
    else
      nil
    end
  end

  # Get adoption action button text and state
  def adoption_action_button_state(pet)
    return :sign_in unless user_signed_in?
    return :unavailable unless pet.available?

    if pet.approved_for_user?(current_user)
      :approved
    elsif pet.pending_for_user?(current_user)
      :pending
    else
      :request
    end
  end

  # Get adoption action button label
  def adoption_action_button_label(pet, state = nil)
    state ||= adoption_action_button_state(pet)

    case state
    when :approved
      'Already Approved'
    when :pending
      'Pending Review'
    when :request
      'Request to Adopt'
    when :sign_in
      'Sign In to Adopt'
    when :unavailable
      'Not Available'
    else
      'Request to Adopt'
    end
  end

  # Render adoption status message in show view
  def adoption_status_message(pet)
    return nil unless user_signed_in?

    case adoption_action_button_state(pet)
    when :approved
      'You have already been approved to adopt this pet. Please contact us for next steps.'
    when :pending
      'Your adoption request for this pet is under review. We will notify you as soon as we have an update.'
    else
      nil
    end
  end
end
