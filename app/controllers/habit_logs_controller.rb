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
    Rails.logger.info "🔥 DEBUG destroy params = #{params.to_unsafe_h}"

    if @habit_log.save
      flash.now[:notice] = "習慣記録を登録しました。"

      respond_to do |format|
        format.turbo_stream do
          case params[:dom_from]
          when "home"
            @habit_log_home_card = @habit_log
          when "index"
            @habit_log_index_card = @habit_log
          end

          render "habit_logs/create"  # ← destroy に合わせる
        end

        format.html do
          redirect_back fallback_location: home_path,
                        notice: "習慣記録を登録しました。"
        end
      end

    else
      flash.now[:alert] = "習慣記録に失敗しました。"

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "habit_logs/modal_edit",
            locals: { habit_log: @habit_log }
          )
        end
        format.html { redirect_back fallback_location: home_path, alert: "習慣記録に失敗しました。" }
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
    respond_to do |format|
      if @habit_log.update(habit_log_params)
        flash.now[:notice] = "習慣記録を更新しました。"

        format.turbo_stream do
          case params[:dom_from]
          when "home"
            @habit_log_home_card = @habit_log
          when "index"
            @habit_log_index_card = @habit_log
          end
        end

        format.html do
          redirect_back fallback_location: home_path,
                        notice: "習慣記録を更新しました。"
        end

      else
        flash.now[:alert] = "更新に失敗しました。"

        format.turbo_stream do
          case params[:from]
          when "edit"
            render turbo_stream: turbo_stream.replace(
              "modal",
              partial: "habit_logs/modal_edit",
              locals: { habit_log: @habit_log }
            )
          else
            render turbo_stream: turbo_stream.replace(
              "modal",
              partial: "habit_logs/modal_show",
              locals: { habit_log: @habit_log }
            )
          end
        end

        format.html do
          redirect_back fallback_location: home_path,
                        alert: "更新に失敗しました。"
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      if @habit_log.destroy
        flash.now[:notice] = "習慣記録を削除しました。"

        format.turbo_stream do
          case params[:dom_from]
          when "home"
            @habit_log_home_card = @habit_log
          when "index"
            @habit_log_index_card = @habit_log
          end
        end

        format.html do
          redirect_back fallback_location: home_path,
                        notice: "習慣記録を削除しました。"
        end

      else
        flash.now[:alert] = "削除に失敗しました。"

        format.turbo_stream do
          case params[:from]
          when "edit"
            render turbo_stream: turbo_stream.replace(
              "modal",
              partial: "habit_logs/modal_edit",
              locals: { habit_log: @habit_log }
            )
          else
            render turbo_stream: turbo_stream.replace(
              "modal",
              partial: "habit_logs/modal_show",
              locals: { habit_log: @habit_log }
            )
          end
        end

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
