class AdminMailer < ApplicationMailer
  default from: ENV['MAIL_FROM_ADDRESS'] || 'noreply@pethavenHub.com'

  # Notification when new pet is listed
  def new_pet_added_notification(pet)
    @pet = pet
    @admin_emails = User.where(role: 'admin').pluck(:email)
    
    mail(to: @admin_emails, subject: "New pet listing: #{@pet.name}")
  end

  # Notification when new request is submitted
  def new_request_notification(request)
    @request = request
    @pet = @request.pet
    @user = @request.user
    @admin_emails = User.where(role: 'admin').pluck(:email)
    
    mail(to: @admin_emails, subject: "New #{@request.request_type} request for #{@pet.name}")
  end

  # Daily summary of pending requests
  def daily_summary(admin)
    @admin = admin
    @pending_requests = Request.where(status: 'open')
    @approved_requests = Request.where(status: 'approved')
    @new_pets = Pet.where('created_at >= ?', 24.hours.ago)
    
    mail(to: @admin.email, subject: 'Daily Pet Haven Hub Summary')
  end

  # Notification for requests pending approval beyond threshold
  def overdue_requests_alert(admin, requests)
    @admin = admin
    @requests = requests
    @threshold_days = 7
    
    mail(to: @admin.email, subject: "Alert: #{@requests.count} pending requests")
  end

  # System report and statistics
  def weekly_statistics_report(admin)
    @admin = admin
    @stats = {
      new_users: User.where('created_at >= ?', 7.days.ago).count,
      new_pets: Pet.where('created_at >= ?', 7.days.ago).count,
      new_requests: Request.where('created_at >= ?', 7.days.ago).count,
      completed_adoptions: Request.where(request_type: 'adopt', status: 'completed', 'completed_at >= ?': 7.days.ago).count,
      average_approval_time: calculate_average_approval_time
    }
    
    mail(to: @admin.email, subject: 'Weekly Pet Haven Hub Report')
  end

  private

  def calculate_average_approval_time
    approved_requests = Request.where(status: 'approved').where('updated_at IS NOT NULL')
    return 0 if approved_requests.empty?
    
    total_time = approved_requests.sum { |req| (req.updated_at - req.created_at) / 1.hour }
    (total_time / approved_requests.count).round(2)
  end
end
