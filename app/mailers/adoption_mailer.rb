# app/mailers/adoption_mailer.rb
class AdoptionMailer < ApplicationMailer

  # → Sent to ALL ADMINS when a user submits an adoption request
  def notify_admin(adoption_request)
    @request             = adoption_request
    @user                = adoption_request.user
    @pet                 = adoption_request.pet
    @admin_dashboard_url = admin_requests_url

    admin_emails = fetch_admin_emails
    return if admin_emails.blank?

    mail(
      to:      admin_emails,
      subject: "🐾 New Adoption Request: #{@pet&.name} — Action Required | #{APP_NAME}"
    )
  end

  # → Sent to USER when admin approves adoption request
  def request_approved(adoption_request)
    @request = adoption_request
    @user    = adoption_request.user
    @pet     = adoption_request.pet
    @pet_url = pet_url(@pet) if @pet.present?
    @adoption_date = adoption_request.adoption_date
    @admin_note = adoption_request.admin_note
    @adoption_center_location = "Panauti, Kathmandu, Nepal"
    @adoption_center_name = "Pet Haven Hub"

    return if @user&.email.blank?

    mail(
      to:      @user.email,
      subject: "🎉 Your Adoption Request for #{@pet&.name} has been Approved!"
    )
  end

  # → Sent to USER when admin rejects adoption request
  def request_rejected(adoption_request)
    @request          = adoption_request
    @user             = adoption_request.user
    @pet              = adoption_request.pet
    @rejection_reason = adoption_request.rejection_reason
    @rejection_reason_enum = adoption_request.rejection_reason_enum
    @admin_message = adoption_request.admin_message
    @rejection_reason_text = format_rejection_reason(@rejection_reason_enum)

    return if @user&.email.blank?

    mail(
      to:      @user.email,
      subject: "Update on Your Adoption Request for #{@pet&.name}"
    )
  end

  # → Sent to USER when adoption is marked complete
  def request_completed(adoption_request)
    @request = adoption_request
    @user    = adoption_request.user
    @pet     = adoption_request.pet
    @pet_url = pet_url(@pet) if @pet.present?

    return if @user&.email.blank?

    mail(
      to:      @user.email,
      subject: "🏡 Congratulations! Your Adoption of #{@pet&.name} is Complete!"
    )
  end

  # → Reminder to USER while adoption request is still pending
  def pending_reminder(adoption_request)
    @request      = adoption_request
    @user         = adoption_request.user
    @pet          = adoption_request.pet
    @days_pending = (Date.today - adoption_request.created_at.to_date).to_i
    @requests_url = requests_url

    return if @user&.email.blank?

    mail(
      to:      @user.email,
      subject: "⏳ Reminder: Your Adoption Request for #{@pet&.name} is Being Reviewed"
    )
  end

  private

  def fetch_admin_emails
    emails = User.where(role: 'admin').pluck(:email).compact
    emails.presence || [ENV['ADMIN_EMAIL']].compact
  end

  def format_rejection_reason(reason_enum)
    case reason_enum
    when 'already_adopted'
      'The pet has already been adopted'
    when 'unsuitable_home'
      'The home environment may not be suitable for this pet'
    when 'incomplete_profile'
      'Your profile information is incomplete'
    when 'duplicate_request'
      'A duplicate request was detected'
    when 'reserved_for_other'
      'The pet has been reserved for another user'
    when 'other'
      'Other reason'
    else
      'Your request does not meet our adoption criteria'
    end
  end
end