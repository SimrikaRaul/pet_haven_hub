# app/mailers/request_mailer.rb
class RequestMailer < ApplicationMailer

  # Sent to USER when they submit any request (adopt, foster, etc.)
  def request_confirmation(request)
    @request      = request
    @user         = request.user
    @pet          = request.pet
    @request_type = request.request_type&.capitalize

    mail(
      to:      @user.email,
      subject: "#{@request_type} Request Confirmation - #{@pet.name} | #{APP_NAME}"
    )
  end

  # Sent to USER when admin approves their request
  def request_approved(request)
    @request      = request
    @user         = request.user
    @pet          = request.pet
    @admin_email  = ENV.fetch('ADMIN_EMAIL', SUPPORT_EMAIL)
    @request_type = request.request_type&.capitalize

    mail(
      to:      @user.email,
      subject: "✅ Your #{@request_type} Request for #{@pet.name} has been Approved!"
    )
  end

  # Sent to USER when admin rejects their request
  def request_rejected(request)
    @request      = request
    @user         = request.user
    @pet          = request.pet
    @reason       = request.rejection_reason
    @request_type = request.request_type&.capitalize

    mail(
      to:      @user.email,
      subject: "Update on your #{@request_type} Request for #{@pet.name}"
    )
  end

  # Sent to USER when their request is marked complete
  def request_completed(request)
    @request      = request
    @user         = request.user
    @pet          = request.pet
    @completed_at = request.completed_at
    @request_type = request.request_type&.capitalize

    mail(
      to:      @user.email,
      subject: "🎉 Your #{@request_type} Request for #{@pet.name} is Complete!"
    )
  end

  # Sent to USER as a reminder that their request is still pending
  def pending_request_reminder(request)
    @request      = request
    @user         = request.user
    @pet          = request.pet
    @request_type = request.request_type&.capitalize
    @days         = (Date.today - request.created_at.to_date).to_i

    mail(
      to:      @user.email,
      subject: "Reminder: Your #{@request_type} Request for #{@pet.name} is Pending"
    )
  end
end