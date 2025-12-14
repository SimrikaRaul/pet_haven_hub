class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  # Authentication should run FIRST
  before_action :authenticate_user!, unless: :public_controller?
  
  # Prevent caching of authenticated pages to avoid stale user data
  before_action :set_cache_headers, if: :user_signed_in?
  
  # Debug logging for user sessions in development
  before_action :log_current_user, if: -> { Rails.env.development? && user_signed_in? }

  # Devise parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Rescue handlers
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Helper methods available in views
  helper_method :admin_user?, :current_admin

  protected

  # Check if current user is an admin
  def admin_user?
    current_user&.admin?
  end

  # Return current admin or nil
  def current_admin
    current_user if admin_user?
  end

  def require_admin
    unless admin_user?
      redirect_to root_path, alert: 'You are not authorized to access this page.'
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :phone, :address, :city, :country, :latitude, :longitude])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :phone, :address, :city, :country, :latitude, :longitude])
  end

  def after_sign_in_path_for(resource)
    resource.admin? ? admin_dashboard_path : root_path
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

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end

  def log_current_user
    Rails.logger.debug "🔍 Current User: ID=#{current_user.id}, Name='#{current_user.name}', Email='#{current_user.email}', Role='#{current_user.role}'"
  end
end
