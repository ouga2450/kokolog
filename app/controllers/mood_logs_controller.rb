class MoodLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    # ログインユーザーの気分登録を新しい順に取得
    @mood_logs = current_user.mood_logs.includes(:mood).recent
  end

  def new
  end

  def create
  end
end
