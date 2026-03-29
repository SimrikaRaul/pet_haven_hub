module Admin
  class RequestsController < Admin::BaseController
    before_action :set_request, only: [:show, :update, :approve, :reject]

    def index
      @requests = Request.recent.page(params[:page]).per(20)
      @status_filter = params[:status]
      @requests = @requests.where(status: @status_filter) if @status_filter.present?
      
      @stats = {
        total: Request.count,
        open: Request.where(status: ['open', 'pending']).count,
        approved: Request.where(status: 'approved').count,
        rejected: Request.where(status: 'rejected').count,
        completed: Request.where(status: 'completed').count
      }
    end

    def show
      @available_dates = Request.available_dates_for_scheduling
      @booked_dates = Request.fully_booked_dates
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
      # Handle adoption requests with date scheduling
      if @request.adopt? && @request.can_be_approved?
        if request.post? && params[:request].present?
          # Process approval with adoption_date and admin_note
          approval_params = params.require(:request).permit(:adoption_date, :admin_note)
          
          if @request.update(approval_params.merge(status: 'approved'))
            AdoptionMailer.request_approved(@request).deliver_later
            
            redirect_to admin_requests_path, 
                       notice: "Request approved successfully for #{@request.adoption_date.strftime('%B %-d, %Y')}.",
                       status: :see_other
          else
            @available_dates = Request.available_dates_for_scheduling
            @booked_dates = Request.fully_booked_dates
            render :show, status: :unprocessable_entity
          end
        else
          # Show the approval form (via modal or show view)
          @available_dates = Request.available_dates_for_scheduling
          @booked_dates = Request.fully_booked_dates
          # The approval form will be shown in the show.html.erb view
          render :show
        end
      elsif @request.can_be_approved?
        # For non-adoption requests, approve directly
        @request.update(status: 'approved')
        AdoptionMailer.request_approved(@request).deliver_later
        
        redirect_to admin_requests_path, 
                   notice: 'Request approved successfully.',
                   status: :see_other
      else
        redirect_to admin_requests_path, 
                   alert: 'Cannot approve this request. Pet may not be available.',
                   status: :see_other
      end
    end

    def reject
      if @request.can_be_rejected?
        @request.reject!(params[:reason])
      
        AdoptionMailer.request_rejected(@request).deliver_later
        redirect_to admin_requests_path, notice: 'Request rejected successfully.', status: :see_other
      else
        redirect_to admin_requests_path, alert: 'Cannot reject this request.', status: :see_other
      end
    end

    private

    def set_request
      @request = Request.find(params[:id])
    end

    def request_params
      params.fetch(:request, ActionController::Parameters.new).permit(:status, :notes, :adoption_date, :admin_note)
    end
  end
end
