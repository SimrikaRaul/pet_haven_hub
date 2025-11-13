# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # After signup, redirect to sign-in instead of signing in automatically
  def after_sign_up_path_for(resource)
    new_user_session_path
  end
end
