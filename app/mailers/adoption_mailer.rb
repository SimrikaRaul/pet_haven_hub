class AdoptionMailer < ApplicationMailer
  default from: -> { ENV.fetch('MAIL_FROM_ADDRESS', 'noreply@pethavenhub.com') }


  def notify_admin(adoption_request)
    @request = adoption_request
    @user = @request.user
    @pet = @request.pet
    @admin_dashboard_url = admin_requests_url

  
    admin_emails = fetch_admin_emails
    return if admin_emails.blank?

    mail(
      to: admin_emails,
      subject: "New Adoption Request: #{@pet&.name || 'Unknown Pet'} - Action Required"
    )
  end

  def notify_user(adoption_request)
    @request = adoption_request
    @user = @request.user
    @pet = @request.pet
    @status = @request.status
    @rejection_reason = @request.rejection_reason
    @pet_url = pet_url(@pet) if @pet.present?

    return if @user&.email.blank?

    subject = case @status
              when 'approved'
                "Great News! Your adoption request for #{@pet&.name} has been approved!"
              when 'rejected'
                "Update on your adoption request for #{@pet&.name}"
              when 'completed'
                "Congratulations! Your adoption of #{@pet&.name} is complete!"
              else
                "Update on your adoption request for #{@pet&.name}"
              end

    mail(
      to: @user.email,
      subject: subject
    )
  end

 
  def pending_reminder(adoption_request)
    @request = adoption_request
    @user = @request.user
    @pet = @request.pet
    @days_pending = @request.days_pending
    @requests_url = requests_url

    return if @user&.email.blank?

    mail(
      to: @user.email,
      subject: "Reminder: Your adoption request for #{@pet&.name} is being reviewed"
    )
  end

  private

  def fetch_admin_emails

    admin_emails = User.where(role: 'admin').pluck(:email).compact


    if admin_emails.blank? && ENV['ADMIN_EMAIL'].present?
      admin_emails = [ENV['ADMIN_EMAIL']]
    end

    admin_emails
  end
end
