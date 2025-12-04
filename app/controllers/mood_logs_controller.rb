class MoodLogsController < ApplicationController
  before_action :set_mood_log, only: [ :show, :edit, :update, :destroy ]

  def new
    @mood_log = MoodLog.new(
      user: current_user,
      mood_id: params[:mood_id],
      feeling_id: params[:feeling_id],
      habit_log_id: params[:habit_log_id],
      timing: params[:timing],
      recorded_at: Time.current
    )

    render :new, layout: false if turbo_frame_request?
  end

  def create
    @mood_log = current_user.mood_logs.build(mood_log_params)

    if @mood_log.save
      @mood_logs_exists_today = current_user.mood_logs.for_today.exists?
      flash.now[:notice] = "気分を記録しました。"

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: home_path,
                        notice: "気分を記録しました。"
        end
      end
    else
      flash.now[:alert] = "気分記録に失敗しました。"

      respond_to do |format|
        format.turbo_stream { render :create_failure }
        format.html do
          redirect_back fallback_location: home_path,
                        alert: "気分記録に失敗しました。"
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
    if @mood_log.update(mood_log_params)
      flash.now[:notice] = "気分記録を更新しました。"

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: home_path,
                        notice: "気分記録を更新しました。"
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
    if @mood_log.destroy
      @mood_logs_none_today = !current_user.mood_logs.for_today.exists?

      flash.now[:notice] = "気分記録を削除しました。"

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: home_path,
                        notice: "気分記録を削除しました。"
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
