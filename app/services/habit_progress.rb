class HabitProgress
  attr_reader :habit, :frequency, :date

  def initialize(habit:, date: Date.current, frequency: :daily)
    @habit = habit
    @date  = date
    @frequency = frequency
  end

  # 集計
  def total_value
    habit_logs.sum(&:value_for_goal).to_i
  end

  def target_value
    habit.goal.amount.to_i
  end

  def range
    range_for_frequency
  end

  # 判定
  def achieved?
    case habit.goal.goal_unit
    when "check_based"
      habit_logs.exists?
    when "count_based", "time_based"
      habit_logs.sum(:performed_value) >= target_value
    else
      false
    end
  end

  def status
    return :not_applicable unless target_value.positive?

    rate = total_value.to_f / target_value

    case rate
    when 1.0.. then :achieved
    when 0.5...1.0 then :almost
    when 0.1...0.5 then :started
    else :none
    end
  end

  def progress_ratio
    return 0 if target_value.zero?

    ratio = total_value.to_f / target_value
    [ ratio, 1.0 ].min
  end

  def habit_logs
    habit.habit_logs.where(started_at: range_for_frequency)
  end

  private

  # 集計範囲
  def range_for_frequency
    case frequency
    when :daily
      date.all_day
    when :weekly
      date.beginning_of_week..date.end_of_day
    when :monthly
      date.beginning_of_month..date.end_of_day
    else
      raise ArgumentError, "unknown frequency: #{frequency}"
    end
  end
end
