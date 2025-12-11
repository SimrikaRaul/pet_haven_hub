module Admin
  class RequestsController < Admin::BaseController
    before_action :set_request, only: [:show, :update, :approve, :reject]

    def index
      @requests = Request.recent.page(params[:page]).per(20)
      @status_filter = params[:status]
      @requests = @requests.where(status: @status_filter) if @status_filter.present?
      
      @stats = {
        total: Request.count,
        open: Request.where(status: 'open').count,
        approved: Request.where(status: 'approved').count,
        rejected: Request.where(status: 'rejected').count,
        completed: Request.where(status: 'completed').count
      }
    end

    def show
    end

    def update
      update_attrs = request_params.to_h
      update_attrs[:status] = params[:status] if params[:status].present?

      if @request.update(update_attrs)
        redirect_to admin_request_path(@request), notice: 'Request updated successfully.'
      else
        render :show, status: :unprocessable_entity
      end
    end

    def approve
      if @request.can_be_approved?
        @request.approve!
        RouteCalculationJob.perform_later(@request.id)
        redirect_to admin_requests_path, notice: 'Request approved and route calculation scheduled.'
      else
        redirect_to admin_requests_path, alert: 'Cannot approve this request. Pet may not be available.'
      end
    end

    def reject
      if @request.can_be_rejected?
        @request.reject!(params[:reason])
        redirect_to admin_requests_path, notice: 'Request rejected successfully.'
      else
        redirect_to admin_requests_path, alert: 'Cannot reject this request.'
      end
    end

    private

    def set_request
      @request = Request.find(params[:id])
    end

    def request_params
      params.fetch(:request, ActionController::Parameters.new).permit(:status, :notes)
    end
  end
end
