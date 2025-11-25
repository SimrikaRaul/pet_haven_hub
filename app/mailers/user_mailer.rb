class UserMailer < ApplicationMailer
  default from: ENV['MAIL_FROM_ADDRESS'] || 'noreply@pethavenHub.com'

  # Welcome email when user signs up
  def welcome_email(user)
    @user = user
    @url = root_url
    mail(to: @user.email, subject: 'Welcome to Pet Haven Hub!')
  end

  # Password reset notification
  def password_reset_instructions(user, token)
    @user = user
    @reset_password_url = edit_password_reset_url(token)
    mail(to: @user.email, subject: 'Reset your Pet Haven Hub password')
  end

  # Profile update confirmation
  def profile_updated(user)
    @user = user
    mail(to: @user.email, subject: 'Your profile has been updated')
  end

  # Account deletion confirmation
  def account_deleted(user)
    @user = user
    mail(to: @user.email, subject: 'Your Pet Haven Hub account has been deleted')
  end
end
