class LogsController < ApplicationController
  before_action :authenticate_user!

  def index
    # HabitLog と MoodLog のどちらにも存在する日付を一覧化
    log_dates = (
      current_user.habit_logs.pluck(:started_at) +
      current_user.mood_logs.pluck(:recorded_at)
    ).map { |t| t.to_date }.uniq.sort.reverse

    @dates = log_dates
  end

  def show
    @date = Date.parse(params[:date])

    @habit_logs = current_user.habit_logs
      .where(started_at: @date.all_day)
      .order(:started_at)

    @mood_logs = current_user.mood_logs
      .where(recorded_at: @date.all_day)
      .order(:recorded_at)
  end
end
