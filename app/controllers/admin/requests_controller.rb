module Admin
  class RequestsController < Admin::BaseController
    before_action :set_request, only: [:show, :update, :approve, :reject, :mark_as_completed, :mark_as_no_show, :reschedule]

    def index
      @requests = Request.recent
      
      # Apply filters
      @status_filter = params[:status]
      @user_filter = params[:user_name]
      @pet_filter = params[:pet_name]
      
      @requests = @requests.where(status: @status_filter) if @status_filter.present?
      
      # Filter by user name
      if @user_filter.present?
        @requests = @requests.joins(:user).where('users.name ILIKE ?', "%#{@user_filter}%")
      end
      
      # Filter by pet name
      if @pet_filter.present?
        @requests = @requests.joins(:pet).where('pets.name ILIKE ?', "%#{@pet_filter}%")
      end
      
      @requests = @requests.page(params[:page]).per(20)
      
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
          
          # Notify user of approval
          SendEmailJob.perform_later(
            @request.user.email,
            "Your Adoption Request for #{@request.pet.name} has been Approved!",
            "Congratulations! Your adoption request for #{@request.pet.name} has been approved. Adoption date: #{@request.adoption_date.strftime('%B %d, %Y')}"
          )
          
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
        
        # Notify user of approval
        SendEmailJob.perform_later(
          @request.user.email,
          "Your Adoption Request for #{@request.pet.name} has been Approved!",
          "Your adoption request for #{@request.pet.name} has been approved."
        )
        
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
          SendEmailJob.perform_later(
            @request.user.email,
            "Update on Your Adoption Request for #{@request.pet.name}",
            "Unfortunately, your adoption request for #{@request.pet.name} was not approved at this time. Reason: #{rejection_reason_enum}. #{admin_message}"
          )
          
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

    def mark_as_completed
      if @request.can_be_completed?
        if @request.mark_as_completed!
          redirect_to admin_requests_path, 
                     notice: "Adoption for #{@request.pet.name} marked as completed successfully.",
                     status: :see_other
        else
          redirect_to admin_request_path(@request), alert: 'Failed to mark adoption as completed.', status: :see_other
        end
      else
        redirect_to admin_request_path(@request), alert: 'This request cannot be marked as completed.', status: :see_other
      end
    end

    def mark_as_no_show
      if @request.can_be_marked_no_show?
        if @request.mark_as_no_show!
          redirect_to admin_requests_path, 
                     notice: "Request marked as no-show. User has been notified.",
                     status: :see_other
        else
          redirect_to admin_request_path(@request), alert: 'Failed to mark request as no-show.', status: :see_other
        end
      else
        redirect_to admin_request_path(@request), alert: 'This request cannot be marked as no-show.', status: :see_other
      end
    end

    def reschedule
      if @request.can_be_rescheduled?
        if request.post? && params[:request].present?
          new_adoption_date = params.dig(:request, :adoption_date)
          admin_note = params.dig(:request, :admin_note)
          
          if new_adoption_date.blank?
            @available_dates = Request.available_dates_for_scheduling
            @booked_dates = Request.fully_booked_dates
            redirect_to admin_request_path(@request), alert: 'Please select a new adoption date.', status: :see_other
            return
          end
          
          if @request.reschedule!(new_adoption_date, admin_note)
            redirect_to admin_requests_path, 
                       notice: "Request rescheduled successfully for #{new_adoption_date.strftime('%B %-d, %Y')}.",
                       status: :see_other
          else
            @available_dates = Request.available_dates_for_scheduling
            @booked_dates = Request.fully_booked_dates
            redirect_to admin_request_path(@request), alert: 'Failed to reschedule request. Please try again.', status: :see_other
          end
        else
          # Show reschedule form
          @available_dates = Request.available_dates_for_scheduling
          @booked_dates = Request.fully_booked_dates
          render :show
        end
      else
        if @request.no_show? && @request.adopt? && @request.reschedule_count >= 2
          redirect_to admin_request_path(@request), 
                     alert: 'Maximum reschedule attempts (2) have been reached. Request has been rejected.',
                     status: :see_other
        else
          redirect_to admin_request_path(@request), alert: 'This request cannot be rescheduled.', status: :see_other
        end
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
