class HabitsController < ApplicationController
  before_action :set_habit, only: [ :edit, :update, :destroy ]

  def new
    @habit_form = HabitForm.new(user_id: current_user.id)
  end

  def create
    # user_id は水平権限昇格防止のため controller 側で付与する
    @habit_form = HabitForm.new(habit_params.merge(user_id: current_user.id))

    if @habit_form.save
      redirect_to home_path, notice: "習慣を登録しました。"
    else
      flash.now[:alert] = "入力内容に誤りがあります。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @habit_form = HabitForm.from_model(@habit)
  end

  def update
    @habit_form = HabitForm.new(habit_params.merge(id: @habit.id, user_id: current_user.id))

    if @habit_form.update
      redirect_to home_path, notice: "習慣を更新しました。"
    else
      flash.now[:alert] = "入力内容に誤りがあります。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit.destroy
    redirect_to home_path, notice: "習慣を削除しました。"
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
