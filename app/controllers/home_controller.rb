class HomeController < ApplicationController
  def index
    habits_query = HabitQuery.new(user: current_user)
    habit_logs = current_user.habit_logs.recent
    mood_logs = current_user.mood_logs.recent

    # 気分（候補一覧）
    @moods = Mood.order(:score)

    # 行動（Goal種別で分類）
    @habits = habits_query.active_base
    @habits_today = habits_query.habits_for("today")
    @habits_this_week = habits_query.habits_for("this_week")
    @habits_this_month = habits_query.habits_for("this_month")

    # 今日の気分ログ
    @mood_logs_today = mood_logs.for_today

    # 今日の行動ログ
    @habit_logs_today = habit_logs.for_today
  end
end
