class Users::SessionsController < Devise::SessionsController
  def create
    user = User.find_by(email: params[:user][:email])

    if user.nil?
      redirect_to new_user_registration_path, alert: "You need to sign up first."
    else
      super
    end
  end
end
