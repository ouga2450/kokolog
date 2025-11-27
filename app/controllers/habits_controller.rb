class HabitsController < ApplicationController
  before_action :set_habit, only: [ :show, :edit, :update, :destroy ]

  def index
    # 習慣取得
    @habits = current_user.habits.includes(:goal, :category)

    @draft_habits    = @habits.draft
    @active_habits   = @habits.active
    @achieved_habits = @habits.achieved

    @daily_habits   = @active_habits.daily
    @weekly_habits  = @active_habits.weekly
    @monthly_habits = @active_habits.monthly
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
    if @habit.destroy
      respond_to do |format|
        format.turbo_stream do
          case params[:from]
          when "home"
            @habit_home_card = @habit
          when "index"
            @habit_index_card = @habit
          end
          flash.now[:notice] = "習慣を削除しました。"
        end

        format.html do
          redirect_to (request.referer.presence || habits_path),
                      notice: "習慣を削除しました。"
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal-content",
            partial: "habits/modal_show",
            locals: { habit: @habit }
          )
        end

        format.html do
          redirect_to (request.referer.presence || habits_path),
                      alert: "削除に失敗しました。"
        end
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
