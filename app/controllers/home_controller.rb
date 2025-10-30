class HomeController < ApplicationController
  def index
    # ユーザーの気分登録を新しい順に取得
    @mood_logs = @user.mood_logs.includes(:mood).recent
  end

  private

  def set_user
    @user = current_user
  end
end
