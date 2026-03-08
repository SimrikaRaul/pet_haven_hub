class RequestsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :new, :create]
  before_action :set_pet, only: [:new, :create]
  before_action :set_request, only: [:show, :update]
  before_action :check_pet_availability, only: [:new, :create]
  before_action :check_duplicate_request, only: [:new, :create]
  before_action :check_active_request_limit, only: [:new, :create]

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
  
  def new
    @request = Request.new
  end

  def create
    @request = current_user.requests.build(request_params)
    @request.pet = @pet
    @request.status = 'pending'
    
    if @request.save
      RecommendationRefreshJob.perform_later(current_user.id)
      redirect_to pet_path(@pet), notice: 'Your adoption request has been sent to admin. Please wait for approval.', status: :see_other
    else
      render :new, status: :unprocessable_entity
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
    params.require(:request).permit(:request_type, :notes, :scheduled_date, 
                                   :citizenship_number, :phone_number, :address, 
                                   :house_type, :has_other_pets, :experience, :reason,
                                   :citizenship_photo)
  end
  
  def check_pet_availability
    unless @pet.available?
      redirect_to pet_path(@pet), alert: 'This pet is no longer available for adoption.', status: :see_other
    end
  end
  
  def check_duplicate_request
    if current_user.requests.where(pet_id: @pet.id).exists?
      redirect_to pet_path(@pet), alert: 'You have already requested adoption for this pet.', status: :see_other
    end
  end

  def check_active_request_limit
    active_count = current_user.requests.active.count
    if active_count >= Request::MAX_ACTIVE_REQUESTS
      redirect_to pet_path(@pet), alert: 'You already have 3 active adoption requests. Please wait until one request is approved or rejected.', status: :see_other
    end
  end
end
