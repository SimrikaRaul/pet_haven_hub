# User Preferences Controller
# Manages user-entered preferences for pet recommendations
class UserPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_preference, only: [:edit, :update]

  # GET /user_preferences/new
  # GET /user_preferences/edit
  def edit
    @user_preference ||= current_user.build_user_preference
  end

  # POST /user_preferences
  def create
    @user_preference = current_user.build_user_preference(user_preference_params)

    if @user_preference.save
      redirect_to recommendations_path, notice: 'Your preferences have been saved! Here are your recommended pets.'
    else
      render :edit
    end
  end

  # PATCH/PUT /user_preferences
  def update
    if @user_preference.update(user_preference_params)
      redirect_to recommendations_path, notice: 'Your preferences have been updated! Here are your recommended pets.'
    else
      render :edit
    end
  end

  private

  def set_user_preference
    @user_preference = current_user.user_preference || current_user.build_user_preference
  end

  def user_preference_params
    params.require(:user_preference).permit(
      :preferred_energy_level,
      :preferred_temperament,
      :preferred_grooming_needs,
      :preferred_exercise_needs,
      :wants_affectionate_pet,
      :apartment_friendly_required,
      :kids_in_home,
      :has_other_pets
    )
  end
end
