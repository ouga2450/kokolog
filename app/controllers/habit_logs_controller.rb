class HabitLogsController < ApplicationController

  def new
    habit = Habit.find(params[:habit_id])

    @habit_log = HabitLog.new(
      user: current_user,
      habit: habit,
      goal: habit.goal,
      started_at: Time.current
    )

    # モーダル表示のため Turbo Frame を条件分岐
    if turbo_frame_request?
      render :new, layout: false
    end
  end

  def create
    @habit_log = current_user.habit_logs.build(habit_log_params)

    if @habit_log.save
      redirect_back fallback_location: home_path, notice: "習慣を記録しました。"
    else
      redirect_back fallback_location: home_path, alert: "記録に失敗しました。"
    end
  end

  private

  def habit_log_params
    params.require(:habit_log).permit(:habit_id, :started_at, :ended_at, :memo)
  end
end
