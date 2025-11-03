class HomeController < ApplicationController
  def index
    # 全ての気分をスコア順に取得
    @moods = Mood.order(:score)
    # 今日のユーザーの気分登録を新しい順に取得
    @mood_logs_today = current_user.mood_logs.includes(:mood).today.limit(10).recent
  end
end
