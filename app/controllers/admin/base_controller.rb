module Admin
  class BaseController < ApplicationController
    layout 'admin'

    before_action :authenticate_user!
    before_action :authenticate_admin!

    private

    # Ensure only admins can access admin controllers
    def authenticate_admin!
      unless admin_user?
        flash[:alert] = "You are not authorized to access the administration page."
        redirect_to root_path
      end
    end
  end
end
