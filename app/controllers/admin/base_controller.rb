module Admin
  class BaseController < ApplicationController
    layout 'admin'

   
    protect_from_forgery with: :exception, prepend: true
    
    before_action :authenticate_user!      # Ensure user is logged in (from Devise)
    before_action :require_admin           # Ensure user has admin role (from ApplicationController)

    
    helper_method :admin_layout_title
    
    private

   
    def admin_layout_title
      "Admin Dashboard"
    end
  end
end
