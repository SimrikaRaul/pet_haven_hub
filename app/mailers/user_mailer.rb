# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer

  # Sent to USER after signing up
  def welcome_email(user)
    @user = user
    @url  = root_url

    mail(
      to:      @user.email,
      subject: "👋 Welcome to #{APP_NAME}!"
    )
  end

  # Sent to USER for password reset
  def password_reset_instructions(user, token)
    @user               = user
    @reset_password_url = edit_password_reset_url(token)

    mail(
      to:      @user.email,
      subject: "Reset Your #{APP_NAME} Password"
    )
  end

  # Sent to USER after profile is updated
  def profile_updated(user)
    @user = user

    mail(
      to:      @user.email,
      subject: "Your #{APP_NAME} Profile Has Been Updated"
    )
  end

  # Sent to USER when account is deleted
  def account_deleted(user)
    @user = user

    mail(
      to:      @user.email,
      subject: "Your #{APP_NAME} Account Has Been Deleted"
    )
  end
end