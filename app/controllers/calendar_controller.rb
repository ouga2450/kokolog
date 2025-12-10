class CalendarController < ApplicationController
  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current

    beginning = @date.beginning_of_month.beginning_of_week(:monday)
    ending    = @date.end_of_month.end_of_week(:monday)

    # 月全体を一括ロード（DBアクセス2回だけ）
    mood_logs = current_user.mood_logs
                  .where(recorded_at: beginning..ending)
                  .includes(:mood)

    habit_logs = current_user.habit_logs
                  .where(started_at: beginning..ending)
                  .includes(habit: :category)

    # 日付ごとにグルーピング
    @mood_logs_by_day  = mood_logs.group_by { |ml| ml.recorded_at.to_date }
    @habit_logs_by_day = habit_logs.group_by { |hl| hl.started_at.to_date }

    @beginning = beginning
    @ending = ending
  end
end
