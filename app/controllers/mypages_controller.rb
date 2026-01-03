class MypagesController < ApplicationController
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    current_user.update!(user_params)
    redirect_to mypage_path
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
