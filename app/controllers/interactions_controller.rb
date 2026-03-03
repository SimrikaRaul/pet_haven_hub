# Interactions Controller
# Handles like and wishlist toggle actions for pets.
# These interactions feed into the collaborative filtering recommendation system.
#
# Interaction weights:
#   - view = 1 (recorded automatically on pet show page)
#   - like = 2
#   - wishlist = 3
#   - adopt = 5 (recorded automatically when adoption is completed)
#
class InteractionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pet, except: [:index]

  # POST /pets/:pet_id/like
  def like
    current_user.toggle_like!(@pet)
    Rails.logger.info "[Interaction] User #{current_user.id} toggled like on Pet #{@pet.id}"
    
    respond_to do |format|
      format.html { redirect_back fallback_location: pet_path(@pet) }
      format.json do
        render json: { 
          liked: current_user.liked?(@pet),
          likes_count: @pet.likes_count
        }
      end
    end
  end

  # DELETE /pets/:pet_id/like
  def unlike
    current_user.unlike!(@pet)
    Rails.logger.info "[Interaction] User #{current_user.id} unliked Pet #{@pet.id}"
    
    respond_to do |format|
      format.html { redirect_back fallback_location: pet_path(@pet) }
      format.json do
        render json: { 
          liked: false,
          likes_count: @pet.likes_count
        }
      end
    end
  end

  # POST /pets/:pet_id/wishlist
  def wishlist
    current_user.toggle_wishlist!(@pet)
    Rails.logger.info "[Interaction] User #{current_user.id} toggled wishlist on Pet #{@pet.id}"
    
    respond_to do |format|
      format.html { redirect_back fallback_location: pet_path(@pet) }
      format.json do
        render json: { 
          wishlisted: current_user.wishlisted?(@pet),
          wishlists_count: @pet.wishlists_count
        }
      end
    end
  end

  # DELETE /pets/:pet_id/wishlist
  def remove_from_wishlist
    current_user.remove_from_wishlist!(@pet)
    Rails.logger.info "[Interaction] User #{current_user.id} removed Pet #{@pet.id} from wishlist"
    
    respond_to do |format|
      format.html { redirect_back fallback_location: pet_path(@pet) }
      format.json do
        render json: { 
          wishlisted: false,
          wishlists_count: @pet.wishlists_count
        }
      end
    end
  end

  # GET /my_pets - Show user's wishlisted and liked pets
  def index
    @wishlisted_pets = current_user.wishlisted_pets.available.recent
    @liked_pets = current_user.liked_pets.available.recent
  end

  private

  def set_pet
    @pet = Pet.find(params[:id]) if params[:id].present?
  end
end
