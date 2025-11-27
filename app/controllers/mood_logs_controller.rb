class MoodLogsController < ApplicationController
  before_action :set_mood_log, only: [ :show, :edit, :update, :destroy ]

  def create
    @mood_log = current_user.mood_logs.build(mood_log_params)

    if @mood_log.save
      redirect_back fallback_location: home_path, notice: "気分を記録しました。"
    else
      redirect_back fallback_location: home_path, notice: "気分記録に失敗しました。"
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
    if @mood_log.update(mood_log_params)
      flash.now[:notice] = "気分記録を更新しました。"

      respond_to do |format|
        format.turbo_stream do
          render "mood_logs/update"  # update.turbo_stream.erb を明示しても OK
        end

        format.html { redirect_back fallback_location: home_path, notice: "気分記録を更新しました。" }
      end
    else
      flash.now[:alert] = "更新に失敗しました。"

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal-content",
            partial: "mood_logs/modal_form",
            locals: { mood_log: @mood_log }
          )
        end
        format.html { redirect_back fallback_location: home_path, alert: "更新に失敗しました。" }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @mood_log.destroy
        flash.now[:notice] = "気分記録を削除しました。"

        format.turbo_stream
        format.html { redirect_back fallback_location: home_path, notice: "気分記録を削除しました。" }
      else
        flash.now[:alert] = "削除に失敗しました。"

        format.turbo_stream do
          case params[:from]
          when "edit"
            render turbo_stream: turbo_stream.replace(
              "modal-content",
              partial: "mood_logs/modal_form",
              locals: { mood_log: @mood_log }
            )
          when "show"
            render turbo_stream: turbo_stream.replace(
              "modal-content",
              partial: "mood_logs/modal_show",
              locals: { mood_log: @mood_log }
            )
          else
            render turbo_stream: turbo_stream.replace(
              "modal-content",
              partial: "mood_logs/modal_show",
              locals: { mood_log: @mood_log }
            )
          end
        end
        format.html { redirect_back fallback_location: home_path, alert: "削除に失敗しました。" }
      end
    end
  end

  private

  def set_mood_log
    @mood_log = current_user.mood_logs.find(params[:id])
  end

  def mood_log_params
    params.require(:mood_log).permit(
      :mood_id,
      :feeling_id,
      :habit_log_id,
      :timing,
      :note,
      :recorded_at
    )
  end
end
