class ApplicationController < ActionController::Base
  include Pundit::Authorization

  protect_from_forgery with: :exception

  
  before_action :authenticate_user!, unless: :public_controller?
  before_action :set_cache_headers, if: :user_signed_in?
  before_action :log_current_user, if: -> { Rails.env.development? && user_signed_in? }
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Rescue handlers
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

 
  helper_method :admin_user?
  def admin_user?
    current_user&.admin?
  end

  helper_method :shelter_manager?
  def shelter_manager?
    current_user&.shelter_manager?
  end


  helper_method :current_admin
  def current_admin
    current_user if admin_user?
  end


  helper_method :has_admin_access?
  def has_admin_access?
    admin_user? || shelter_manager?
  end

  def require_admin
    unless admin_user?
      flash[:alert] = 'You are not authorized to access this page. Admin access required.'
      redirect_to root_path
    end
  end

  
  def require_shelter_manager
    unless shelter_manager?
      flash[:alert] = 'You are not authorized to access this page. Shelter manager access required.'
      redirect_to root_path
    end
  end


  def require_admin_access
    unless has_admin_access?
      flash[:alert] = 'You are not authorized to access this page. Administrative access required.'
      redirect_to root_path
    end
  end

 
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :phone, :address, :city, :country])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :phone, :address, :city, :country])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || (resource.admin? ? admin_dashboard_path : root_path)
  end


  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

 

  private

  # Controllers that don't require authentication
  def public_controller?
    controller_name.in?(%w[home pets])
  end

  # Handle Pundit authorization errors
  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:alert] = "You are not authorized to perform this action on #{policy_name.gsub('_policy', '')}."
    redirect_to(request.referrer || root_path)
  end

  # Handle record not found errors
  def record_not_found
    flash[:alert] = "The requested record was not found."
    redirect_to(request.referrer || root_path)
  end

  # Prevent caching of authenticated pages to avoid stale user data
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end

  # Debug logging for development
  def log_current_user
    Rails.logger.debug "=" * 80
    Rails.logger.debug "🔍 CURRENT USER SESSION"
    Rails.logger.debug "   User ID:    #{current_user.id}"
    Rails.logger.debug "   Name:       #{current_user.name}"
    Rails.logger.debug "   Email:      #{current_user.email}"
    Rails.logger.debug "   Role:       #{current_user.role}"
    Rails.logger.debug "   Is Admin:   #{admin_user?}"
    Rails.logger.debug "   Session ID: #{session.id}"
    Rails.logger.debug "=" * 80
  end
end
