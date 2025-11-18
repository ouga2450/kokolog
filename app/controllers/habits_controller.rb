class HabitsController < ApplicationController
  before_action :set_habit, only: [ :show, :edit, :update, :destroy ]

  def index
    # 習慣取得
    habits = current_user.habits.includes(:category, :goal).order(:id)
    @habits = habits.limit(10)
    @habits_today = habits.for_today
    @habits_this_week = habits.for_this_week
    @habits_this_month = habits.for_this_month
  end

  def show
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
    @habit.destroy
    redirect_to (request.referer.presence || habits_path),
              notice: "習慣を削除しました。"
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
      :goal_type,
      :target_type,
      :target_value,
      :start_date,
      :end_date
    )
  end
end
