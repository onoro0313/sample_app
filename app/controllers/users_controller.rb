class UsersController < ApplicationController
  def new
    @user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      # moduleの使用/ helperで定義
      flash[:success] = "Welcome to the Sample App!!"
      redirect_to @user
    else
      render 'new'
    end
  end
  def show
    @user = User.find(params[:id])
  end

  private
    def user_params
        params.require(:user).permit(:name, :email, :password,:password_confirmation)
    end
end
