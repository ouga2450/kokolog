class HomeController < ApplicationController
  def index
    # 全ての気分をスコア順に取得
    @moods = Mood.order(:score)
    # 今日のユーザーの気分登録を新しい順に取得
    @mood_logs_today = current_user.mood_logs.includes(:mood, :feeling).today.limit(10).recent
    # 習慣取得
    habits = current_user.habits.includes(:category, :goal).order(:id)
    @habits = habits.limit(10)
    @habits_today = habits.for_today
    @habits_this_week = habits.for_this_week
    @habits_this_month = habits.for_this_month
  end
end
