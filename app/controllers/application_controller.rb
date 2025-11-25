class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  # Authentication should run FIRST
  before_action :authenticate_user!, unless: :public_controller?

  # Devise parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Rescue handlers
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :phone, :address, :city, :country, :latitude, :longitude])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :phone, :address, :city, :country, :latitude, :longitude])
  end

  def after_sign_in_path_for(resource)
    resource.admin? ? admin_path : root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  # 👇 PUBLIC CONTROLLERS FOR VISITORS (NO LOGIN REQUIRED)
  def public_controller?
    controller_name.in?(%w[home pets])
  end

  def user_not_authorized(exception)
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def record_not_found
    flash[:alert] = "Record not found."
    redirect_to(request.referrer || root_path)
  end

  def current_admin
    current_user if current_user&.admin?
  end
end
