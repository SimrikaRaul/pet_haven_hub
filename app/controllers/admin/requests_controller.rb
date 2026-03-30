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
      # Reload to ensure we have the latest status
      @request.reload
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
          adoption_date = params.dig(:request, :adoption_date)
          admin_note = params.dig(:request, :admin_note)
          
          if adoption_date.blank?
            @available_dates = Request.available_dates_for_scheduling
            @booked_dates = Request.fully_booked_dates
            redirect_to admin_request_path(@request), alert: 'Please select an adoption date.', status: :see_other
            return
          end
          
          # Use update_columns to bypass validations (similar to reject)
          @request.update_columns(
            status: 'approved',
            adoption_date: adoption_date,
            admin_note: admin_note,
            updated_at: Time.current
          )
          
          # Reload to ensure status is fresh
          @request.reload
          
          AdoptionMailer.request_approved(@request).deliver_later
          
          redirect_to admin_requests_path, 
                     notice: "Request approved successfully for #{@request.adoption_date.strftime('%B %-d, %Y')}.",
                     status: :see_other
        else
          # Show the approval form (via modal or show view)
          @available_dates = Request.available_dates_for_scheduling
          @booked_dates = Request.fully_booked_dates
          # The approval form will be shown in the show.html.erb view
          render :show
        end
      elsif @request.can_be_approved?
        # For non-adoption requests, approve directly using update_columns
        @request.update_columns(status: 'approved', updated_at: Time.current)
        @request.reload
        
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
        # Extract rejection parameters from the form
        rejection_reason_enum = params[:request]&.fetch(:rejection_reason_enum, nil)
        admin_message = params[:request]&.fetch(:admin_message, nil)
        
        # Validate that a reason was selected
        if rejection_reason_enum.blank?
          redirect_to admin_request_path(@request), alert: 'Please select a rejection reason.', status: :see_other
          return
        end
        
        # Reject the request with the provided details
        if @request.reject!(rejection_reason_enum, admin_message)
          # Send rejection email
          AdoptionMailer.request_rejected(@request).deliver_later
          
          # Reload to ensure status is updated
          @request.reload
          
          redirect_to admin_requests_path, notice: 'Request rejected successfully.', status: :see_other
        else
          redirect_to admin_request_path(@request), alert: 'Failed to reject request. Please try again.', status: :see_other
        end
      else
        redirect_to admin_requests_path, alert: 'Cannot reject this request.', status: :see_other
      end
    end

    private

    def set_request
      @request = Request.find(params[:id])
    end

    def request_params
      params.fetch(:request, ActionController::Parameters.new).permit(:status, :notes, :adoption_date, :admin_note, :rejection_reason_enum, :admin_message)
    end
  end
end
