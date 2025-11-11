class MoodLogsController < ApplicationController
  def create
    @mood_log = current_user.mood_logs.build(mood_log_params)

    if @mood_log.save
      redirect_back fallback_location: home_path, notice: "気分を記録しました。"
    else
      redirect_back fallback_location: home_path, notice: "気分記録に失敗しました。"
    end
  end

  def show
    @mood_log = current_user.mood_logs.find(params[:id])
    if turbo_frame_request?
      render :show, layout: false
    else
      redirect_to home_path
    end
  end

  def edit
    @mood_log = current_user.mood_logs.find(params[:id])
    if turbo_frame_request?
      render :edit, layout: false
    else
      redirect_to home_path
    end
  end

  def update
    @mood_log = current_user.mood_logs.find(params[:id])

    respond_to do |format|
      if @mood_log.update(mood_log_params)
        flash.now[:notice] = "気分記録を更新しました。"
        format.turbo_stream
        format.html { redirect_back fallback_location: home_path, notice: "気分記録を更新しました。" }
      else
        flash.now[:alert] = "更新に失敗しました。"

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "mood_logs/form",
            locals: { mood_log: @mood_log }
          )
        end
        format.html { redirect_back fallback_location: home_path, alert: "更新に失敗しました。" }
      end
    end
  end

  def destroy
    @mood_log = current_user.mood_logs.find(params[:id])

    respond_to do |format|
      if @mood_log.destroy
        flash.now[:notice] = "気分記録を削除しました。"

        format.turbo_stream
        format.html { redirect_back fallback_location: home_path, notice: "気分記録を削除しました。" }
      else
        flash.now[:alert] = "削除に失敗しました。"

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "mood_logs/form",
            locals: { mood_log: @mood_log }
          )
        end
        format.html { redirect_back fallback_location: home_path, alert: "削除に失敗しました。" }
      end
    end
  end

  def mood_log_params
    params.require(:mood_log).permit(:mood_id, :feeling_id, :note, :recorded_at)
  end
end
