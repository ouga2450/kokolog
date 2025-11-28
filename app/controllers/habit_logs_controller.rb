class HabitLogsController < ApplicationController
  before_action :set_habit_log, only: [ :show, :edit, :update, :destroy ]

  def new
    habit = Habit.find(params[:habit_id])

    @habit_log = HabitLog.new(
      user: current_user,
      habit: habit,
      goal: habit.goal,
      started_at: Time.current
    )

    if turbo_frame_request?
      render :new, layout: false
    end
  end

  def create
    @habit_log = current_user.habit_logs.build(habit_log_params)

    if @habit_log.save
      flash.now[:notice] = "習慣記録を登録しました。"

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: home_path,
                        notice: "習慣記録を登録しました。"
        end
      end

    else
      flash.now[:alert] = "習慣記録に失敗しました。"

      respond_to do |format|
        format.turbo_stream { render :create_failure }
        format.html do
          redirect_back fallback_location: home_path,
                          alert: "習慣記録に失敗しました。"
        end
      end
    end
  end

  def show
    if turbo_frame_request?
      render :show, layout: false
    else
      redirect_to home_path
    end
  end

  def edit
    if turbo_frame_request?
      render :edit, layout: false
    else
      redirect_to home_path
    end
  end

  def update

    if @habit_log.update(habit_log_params)
      flash.now[:notice] = "習慣記録を更新しました。"

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: home_path,
                        notice: "習慣記録を更新しました。"
        end
      end

    else
      flash.now[:alert] = "更新に失敗しました。"

      respond_to do |format|
        format.turbo_stream { render :update_failure }
        format.html do
          redirect_back fallback_location: home_path,
                        alert: "更新に失敗しました。"
        end
      end
    end
  end

  def destroy

    if @habit_log.destroy
      @habit_logs_count = HabitLogQuery.new(user: current_user).count_for_today
      flash.now[:notice] = "習慣記録を削除しました。"

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: home_path,
                        notice: "習慣記録を削除しました。"
        end
      end

    else
      flash.now[:alert] = "削除に失敗しました。"

      respond_to do |format|
        format.turbo_stream { render :destroy_failure }
        format.html do
          redirect_back fallback_location: home_path,
                        alert: "削除に失敗しました。"
        end
      end
    end
  end

  private

  def set_habit_log
    @habit_log = current_user.habit_logs.find(params[:id])
  end

  def habit_log_params
    params.require(:habit_log).permit(:habit_id, :goal_id, :performed_value, :started_at, :ended_at)
  end
end
