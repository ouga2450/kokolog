class ReactionContext
  attr_reader :date,
              :mood_logs,
              :habit_logs,
              :habits,
              :avg_mood,
              :mood_graph_values,
              :summaries

  def initialize(user:, date:)
    @user = user
    @date = date
    build
  end

  private

  def build
    build_mood_logs
    build_mood_graph
    build_habit_logs
    build_habits
    build_avg_mood
    build_summaries
  end

  def build_mood_logs
    @mood_logs =
      @user.mood_logs
           .includes(:mood, :feeling)
           .for_date(@date)
           .recent
  end

  def build_mood_graph
    logs_scope =
      @user.mood_logs
           .includes(:mood)
           .for_date(@date)

    aggregation = TimeSeriesAggregation.new(logs_scope).call
    @mood_graph_values = aggregation[:points]
  end

  def build_habit_logs
    @habit_logs =
      @user.habit_logs
           .includes(:habit, mood_logs: :mood)
           .for_date(@date)
           .recent
  end

  def build_habits
    @habits =
      @user.habits
           .includes(:goal, :category)
           .kept
           .with_active_goal
           .with_effective_goal_on(@date)
  end

  def build_avg_mood
    @avg_mood =
      @mood_logs
        .joins(:mood)
        .average("moods.score")
        &.to_f
  end

  def build_summaries
    frequency = %i[daily weekly monthly]

    @summaries =
      frequency.index_with do |frequency|
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
end
