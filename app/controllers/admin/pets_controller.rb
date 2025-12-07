module Admin
  class PetsController < Admin::BaseController
    before_action :set_pet, only: [:show, :edit, :update, :destroy]

    def index
      @pets = Pet.recent.page(params[:page]).per(20)
      @total_pets = Pet.count
      @available_pets = Pet.available.count
      @unavailable_pets = Pet.unavailable.count
    end

    def show
    end

    def new
      @pet = Pet.new
    end

    def create
      @pet = Pet.new(pet_params)
      @pet.user ||= current_user
      if @pet.save
        redirect_to admin_pets_path, notice: 'Pet listing created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @pet.update(pet_params)
        redirect_to admin_pets_path, notice: 'Pet updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      pet_name = @pet.name
      @pet.destroy
      redirect_to admin_pets_path, notice: "Pet '#{pet_name}' has been removed."
    end

    private

    def set_pet
      @pet = Pet.find(params[:id])
    end

    def pet_params
      params.require(:pet).permit(
        :name, :pet_type, :breed, :age, :size, :sex, :description,
        :health_status, :vaccinated, :available, :city, :country,
        :latitude, :longitude, :image
      )
    end
  end
end
