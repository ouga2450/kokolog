class HabitLogsController < ApplicationController
  helper LogStreams
  before_action :set_habit_log, only: [ :show, :edit, :update, :destroy ]

  def new
    habit = current_user.habits.find(params[:habit_id])

    @form = HabitLogForm.new(
      user: current_user,
      habit: habit
    )

    render :new, layout: false if turbo_frame_request?
  end

  def create
    habit = current_user.habits.find(habit_log_params[:habit_id])

    @form = HabitLogForm.new(
      user: current_user,
      habit: habit,
      attributes: habit_log_params
    )

    saver = HabitLogSaver.new(@form)

    if saver.save
      @habit_log = saver.habit_log
      @diffs = saver.diffs

      @habit_logs_exists_today = current_user.habit_logs.for_today.exists?
      @mood_logs_exists_today = current_user.mood_logs.for_today.exists?
      flash.now[:notice] = "行動記録を登録しました。"

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: home_path, notice: "行動記録を登録しました。" }
      end

    else
      flash.now[:alert] = "行動記録に失敗しました。"

      respond_to do |format|
        format.turbo_stream { render :create_failure }
        format.html { redirect_back fallback_location: home_path, alert: "行動記録に失敗しました。" }
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
    @form = HabitLogForm.new(
      user: current_user,
      habit_log: @habit_log,
    )

    @mood_logs = @habit_log.mood_logs

    render :edit, layout: false if turbo_frame_request?
  end

  def update
    @form = HabitLogForm.new(
      user: current_user,
      habit_log: @habit_log,
      attributes: habit_log_params
    )

    saver = HabitLogSaver.new(@form)

    if saver.save
      @habit_log =saver.habit_log
      @diffs = saver.diffs

      @habit_logs_exists_today = current_user.habit_logs.for_today.exists?
      @mood_logs_exists_today = current_user.mood_logs.for_today.exists?

      flash.now[:notice] = "行動記録を更新しました。"

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: home_path, notice: "行動記録を更新しました。" }
      end

    else
      flash.now[:alert] = "更新に失敗しました。"

      respond_to do |format|
        format.turbo_stream { render :update_failure }
        format.html { redirect_back fallback_location: home_path, alert: "更新に失敗しました。" }
      end
    end
  end

  def destroy
    if @habit_log.destroy
      @habit_logs_exists_today = current_user.habit_logs.for_today.exists?
      flash.now[:notice] = "行動記録を削除しました。"

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: home_path, notice: "行動記録を削除しました。" }
      end

    else
      flash.now[:alert] = "削除に失敗しました。"

      respond_to do |format|
        format.turbo_stream { render :destroy_failure }
        format.html { redirect_back fallback_location: home_path, alert: "削除に失敗しました。" }
      end
    end
  end

  private

  def set_habit_log
    @habit_log = current_user.habit_logs.includes(:habit, mood_logs: [ :mood, :feeling ]).find(params[:id])
  end

  def habit_log_params
    params.require(:habit_log).permit(
      :id,
      :habit_id,
      :goal_id,
      :performed_value,
      :started_at,
      :ended_at,
      # before
      :before_mood_id,
      :before_feeling_id,
      :before_note,
      :before_recorded_at,
      # after
      :after_mood_id,
      :after_feeling_id,
      :after_note,
      :after_recorded_at
    )
  end
end
