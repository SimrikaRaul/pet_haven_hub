# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :check_sign_in

  private

  def check_sign_in
    # Skip for Devise controllers (sign_in, sign_up, etc.)
    return if devise_controller?

    unless user_signed_in?
      redirect_to new_user_registration_path
    end
  end
end
