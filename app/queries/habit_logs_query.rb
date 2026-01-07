class HabitLogsQuery
  def initialize(user:, habit:, date:, frequency:)
    @user = user
    @habit = habit
    @date = date
    @frequency = frequency
  end

  def range
    case @frequency
    when :daily
      @date.all_day
    when :weekly
      @date.beginning_of_week..@date.end_of_day
    when :monthly
      @date.beginning_of_month..@date.end_of_day
    else
      raise ArgumentError, "unknown frequency"
    end
  end

  def logs
    @logs ||= @user.habit_logs.where(
      habit_id: @habit.id,
      started_at: range
    )
  end
end
