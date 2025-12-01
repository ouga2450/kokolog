class HomeController < ApplicationController
  def index
    habit_query = HabitQuery.new(user: current_user)
    habit_log_query = HabitLogQuery.new(user: current_user)
    mood_log_query = MoodLogQuery.new(user: current_user)

    # 気分（候補一覧）
    @moods = Mood.order(:score)

    # 習慣（Goal種別で分類）
    @habits = habit_query.active_base
    @habits_today = habit_query.habits_for("today")
    @habits_this_week = habit_query.habits_for("this_week")
    @habits_this_month = habit_query.habits_for("this_month")

    # 今日の気分ログ
    @mood_logs_today = mood_log_query.today_logs

    # 今日の習慣ログ
    @habit_logs_today = habit_log_query.today_logs
  end
end
