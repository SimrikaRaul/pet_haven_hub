module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy, :make_admin, :remove_admin]

    def index
      @users = User.recent.page(params[:page]).per(20)
      @total_users = User.count
      @admin_users = User.where(role: 'admin').count
      @active_users = User.active_users.count
    end

    def show
      @user_requests = @user.requests.limit(10)
      @user_pets = @user.pets.limit(10)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: 'User updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: 'User deleted successfully.'
    end

    def make_admin
      @user.update(role: 'admin')
      redirect_to admin_user_path(@user), notice: "#{@user.name} is now an admin."
    end

    def remove_admin
      @user.update(role: 'user')
      redirect_to admin_user_path(@user), notice: "#{@user.name} is no longer an admin."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :phone, :address, :city, :country)
    end
  end
end
