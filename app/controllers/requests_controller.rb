class RequestsController < ApplicationController
  before_action :authenticate_user!,only: [:index, :create]
  before_action :set_pet, only: [:create]
  before_action :set_request, only: [:show, :update]

  def index
    if current_user&.admin?
      @requests = Request.recent.page(params[:page]).per(20)
    else
      @requests = current_user.requests.recent.page(params[:page]).per(10)
    end
    @open_count = Request.where(status: 'open').count
    @approved_count = Request.where(status: 'approved').count
    @completed_count = Request.where(status: 'completed').count
  end

  def show
    authorize @request
  end

  def create
    @request = current_user.requests.build(request_params)
    @request.pet = @pet
    @request.status = 'open'
    
    if @request.save
      RecommendationRefreshJob.perform_later(current_user.id)
      redirect_to @pet, notice: 'Adoption/Donation request submitted successfully.'
    else
      redirect_to @pet, alert: @request.errors.full_messages.to_sentence
    end
  end

  def update
    authorize @request
    if @request.update(request_params)
      redirect_to @request, notice: 'Request updated successfully.'
    else
      redirect_to @request, alert: @request.errors.full_messages.to_sentence
    end
  end

  private

  def set_pet
    @pet = Pet.find(params[:pet_id])
  end

  def set_request
    @request = Request.find(params[:id])
  end

  def request_params
    params.require(:request).permit(:request_type, :notes, :scheduled_date)
  end
end
