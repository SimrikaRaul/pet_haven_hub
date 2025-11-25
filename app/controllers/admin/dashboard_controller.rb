module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
      @stats = {
        total_pets: Pet.count,
        available_pets: Pet.available.count,
        unavailable_pets: Pet.unavailable.count,
        total_users: User.count,
        total_requests: Request.count,
        open_requests: Request.where(status: 'open').count,
        approved_requests: Request.where(status: 'approved').count,
        rejected_requests: Request.where(status: 'rejected').count,
        completed_requests: Request.where(status: 'completed').count,
        adoption_requests: Request.where(request_type: 'adopt').count,
        donation_requests: Request.where(request_type: 'donate').count
      }

      @recent_pets = Pet.recent.limit(5)
      @recent_requests = Request.recent.limit(10)
      @pending_requests = Request.where(status: 'open').limit(10)
      
      # Activity chart data
      @requests_by_date = Request.group_by_day(:created_at).count.last(30)
      @adoptions_by_pet_type = Request.where(request_type: 'adopt').joins(:pet).group('pets.pet_type').count
    end

    private

    def authorize_admin!
      redirect_to root_path, alert: 'Not authorized' unless current_user&.admin?
    end
  end
end
