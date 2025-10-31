class MoodLogsController < ApplicationController
  def create
    @mood_log = current_user.mood_logs.build(mood_log_params)

    if @mood_log.save
      redirect_back fallback_location: home_path, notice: "気分を記録しました。"
    else
      redirect_back fallback_location: home_path, notice: "気分記録に失敗しました。"
    end
  end

  private

  def mood_log_params
    params.require(:mood_log).permit(:mood_id, :feeling_id, :note, :logged_at)
  end
end
