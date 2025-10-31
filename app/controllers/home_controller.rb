class HomeController < ApplicationController
  def index
    # 全ての気分をスコア順に取得
    @moods = Mood.order(:score)
    # ユーザーの気分登録を新しい順に取得
    @mood_logs = @user.mood_logs.includes(:mood).recent
  end
end
