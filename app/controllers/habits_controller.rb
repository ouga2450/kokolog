class HabitsController < ApplicationController
  before_action :set_habit, only: [ :show, :edit, :update, :destroy ]

  def index
    base = current_user.habits
                        .includes(:goal, :category)
    
    kept = base.kept

    @daily_habits   = kept.with_active_goal.daily
    @weekly_habits  = kept.with_active_goal.weekly
    @monthly_habits = kept.with_active_goal.monthly

    @draft_habits    = kept.with_draft_goal
    @achieved_habits = kept.with_achieved_goal

    @discarded_habits = base.discarded
  end

  def show
    @progress = HabitProgress.new(habit: @habit)
    if turbo_frame_request?
      render :show, layout: false
    else
      redirect_to home_path
    end
  end

  def new
    session[:habit_return_to] = request.referer
    @habit_form = HabitForm.new(user_id: current_user.id)
  end

  def create
    # user_id は水平権限昇格防止のため controller 側で付与する
    @habit_form = HabitForm.new(habit_params.merge(user_id: current_user.id))

    if @habit_form.save
      redirect_to(session.delete(:habit_return_to) || habits_path,
                  notice: "習慣を登録しました。")
    else
      flash.now[:alert] = "入力内容に誤りがあります。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    session[:habit_return_to] = request.referer
    @habit_form = HabitForm.from_model(@habit)
  end

  def update
    @habit_form = HabitForm.new(habit_params.merge(id: @habit.id, user_id: current_user.id))

    if @habit_form.update
      redirect_to(session.delete(:habit_return_to) || habits_path,
                  notice: "習慣を更新しました。")
    else
      flash.now[:alert] = "入力内容に誤りがあります。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit.archive!

    query = HabitQuery.new(user: current_user)
    @none_flag = query.none_for?(params[:tab])

    flash.now[:notice] = "習慣をアーカイブしました。"

    respond_to do |format|
      format.turbo_stream
      format.html do
        redirect_to (request.referer.presence || habits_path),
                    notice: "習慣をアーカイブしました。"
      end
    end

  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = "アーカイブに失敗しました。"

    respond_to do |format|
      format.turbo_stream { render :destroy_failure }
      format.html do
        redirect_to (request.referer.presence || habits_path),
                    alert: "アーカイブに失敗しました。"
      end
    end
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit_form).permit(
      :name,
      :description,
      :category_id,
      :goal_unit,
      :frequency,
      :amount,
      :start_date,
      :end_date,
      :status
    )
  end
end
