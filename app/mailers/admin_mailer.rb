# app/mailers/admin_mailer.rb
class AdminMailer < ApplicationMailer

  # Sent to ALL ADMINS when a new pet is listed
  def new_pet_added_notification(pet)
    @pet          = pet
    @admin_emails = admin_emails

    mail(
      to:      @admin_emails,
      subject: "🐾 New Pet Listing: #{@pet.name} | #{APP_NAME}"
    )
  end

  # Sent to ALL ADMINS when any new request is submitted
  def new_request_notification(request)
    @request      = request
    @pet          = request.pet
    @user         = request.user
    @admin_emails = admin_emails

    mail(
      to:      @admin_emails,
      subject: "📋 New #{request.request_type&.capitalize} Request for #{@pet.name} | #{APP_NAME}"
    )
  end

  # Daily digest of all pending/approved requests — sent to one admin
  def daily_summary(admin)
    @admin             = admin
    # Fixed: use 'pending' not 'open' (matches your schema)
    @pending_requests  = Request.where(status: 'pending')
    @approved_requests = Request.where(status: 'approved')
    @new_pets          = Pet.where('created_at >= ?', 24.hours.ago)

    mail(
      to:      @admin.email,
      subject: "📊 Daily Summary — #{Date.today.strftime('%B %d, %Y')} | #{APP_NAME}"
    )
  end

  # Alert to admin when requests have been pending too long
  def overdue_requests_alert(admin, requests)
    @admin          = admin
    @requests       = requests
    @threshold_days = 7

    mail(
      to:      @admin.email,
      subject: "🚨 Alert: #{requests.count} Requests Pending Over #{@threshold_days} Days | #{APP_NAME}"
    )
  end

  # Weekly stats report sent to one admin
  def weekly_statistics_report(admin)
    @admin = admin
    @stats = {
      new_users:            User.where('created_at >= ?', 7.days.ago).count,
      new_pets:             Pet.where('created_at >= ?', 7.days.ago).count,
      new_requests:         Request.where('created_at >= ?', 7.days.ago).count,
      # Fixed: chained .where instead of hash syntax (was causing crash)
      completed_adoptions:  Request.where(request_type: 'adopt', status: 'completed')
                                   .where('completed_at >= ?', 7.days.ago).count,
      average_approval_time: calculate_average_approval_time
    }

    mail(
      to:      @admin.email,
      subject: "📈 Weekly Report — #{Date.today.strftime('%B %d, %Y')} | #{APP_NAME}"
    )
  end

  private

  def admin_emails
    User.where(role: 'admin').pluck(:email).compact
  end

  def calculate_average_approval_time
    # Fixed: use .where.not instead of deprecated condition
    approved = Request.where(status: 'approved').where.not(updated_at: nil)
    return 0 if approved.empty?

    total = approved.sum { |r| (r.updated_at - r.created_at) / 1.hour }
    (total / approved.count).round(2)
  end
end