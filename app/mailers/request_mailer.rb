class RequestMailer < ApplicationMailer
  default from: ENV['MAIL_FROM_ADDRESS'] || 'noreply@pethavenHub.com'

  # Confirmation when request is created
  def request_confirmation(request)
    @request = request
    @user = @request.user
    @pet = @request.pet
    @request_type = @request.request_type.capitalize
    
    mail(to: @user.email, subject: "#{@request_type} Request Confirmation - #{@pet.name}")
  end

  # Notification when request is approved
  def request_approved(request)
    @request = request
    @user = @request.user
    @pet = @request.pet
    @admin_email = User.where(role: 'admin').first&.email
    
    mail(to: @user.email, subject: "Your #{@request.request_type} request for #{@pet.name} has been approved!")
  end

  # Notification when request is rejected
  def request_rejected(request)
    @request = request
    @user = @request.user
    @pet = @request.pet
    @reason = @request.rejection_reason
    
    mail(to: @user.email, subject: "Update on your #{@request.request_type} request for #{@pet.name}")
  end

  # Notification when delivery route is calculated
  def route_calculated(request)
    @request = request
    @user = @request.user
    @pet = @request.pet
    @distance = @request.route_distance_in_km
    @route = @request.route
    
    mail(to: @user.email, subject: "Delivery route for #{@pet.name} is ready")
  end

  # Notification when request is completed
  def request_completed(request)
    @request = request
    @user = @request.user
    @pet = @request.pet
    @completed_at = @request.completed_at
    
    mail(to: @user.email, subject: "Your #{@request.request_type} request for #{@pet.name} is complete!")
  end

  # Reminder for pending requests
  def pending_request_reminder(request)
    @request = request
    @user = @request.user
    @pet = @request.pet
    @days = @request.days_pending
    
    mail(to: @user.email, subject: "Reminder: Your #{@request.request_type} request is pending")
  end
end
