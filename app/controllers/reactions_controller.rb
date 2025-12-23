class ReactionsController < ApplicationController
  def show
    @date = parse_date(params[:date]) || Date.current

    # --- その日のログ ---
    @mood_logs =
      current_user.mood_logs
                  .includes(:mood, :feeling)
                  .for_date(@date)
                  .recent

    @habit_logs =
      current_user.habit_logs
                  .includes(:habit, mood_logs: :mood)
                  .for_date(@date)
                  .recent

    @habits =
      current_user.habits
                  .includes(:goal, :category)
                  .kept
                  .with_active_goal
                  .with_effective_goal_on(@date)

    # --- 平均気分 ---
    @avg_mood =
      @mood_logs
        .joins(:mood)
        .average("moods.score")
        &.to_f

    # --- 行動集計（結果） ---
    frequency = %i[daily weekly monthly]

    @summaries =
      frequency.index_with do |frequency|
        # Habit.noneを返すことでActiveRecord::Relationとなる
        frequency_habits = @habits.public_send(frequency) || Habit.none
        progresses =
          frequency_habits.map do |habit|
            HabitProgress.new(
              habit: habit,
              date: @date,
              frequency: frequency
            )
          end

        HabitProgressSummary.new(progresses, @date, frequency)
      end
  end


  private

  def parse_date(str)
    return nil if str.blank?
    Date.parse(str)
  rescue ArgumentError
    nil
  end
end
