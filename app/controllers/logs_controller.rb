class LogsController < ApplicationController
  before_action :authenticate_user!

  def index
    # HabitLog と MoodLog のタイムスタンプから日付一覧を作成
    log_dates =
      current_user.habit_logs.pluck(:started_at) +
      current_user.mood_logs.pluck(:recorded_at)

    @dates = log_dates
      .compact                  # nil を除外
      .map(&:to_date)           # 日付に変換
      .uniq
      .sort
      .reverse                  # 新しい日付から順に

    # 日付ごとの件数集計
    @log_counts = @dates.index_with do |date|
      {
        habit_logs: current_user.habit_logs.where(started_at: date.all_day).count,
        mood_logs:  current_user.mood_logs.where(recorded_at: date.all_day).count
      }
    end
  end

  def show
    @date = Date.parse(params[:date]) rescue nil

    if @date.nil?
      redirect_to logs_path, alert: "無効な日付です"
      return
    end

    @habit_logs = current_user.habit_logs
      .where(started_at: @date.all_day)
      .order(:started_at)

    @mood_logs = current_user.mood_logs
      .where(recorded_at: @date.all_day)
      .order(:recorded_at)
  end
end
