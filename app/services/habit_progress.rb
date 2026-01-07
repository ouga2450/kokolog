class HabitProgress
  attr_reader :habit, :habit_logs, :frequency, :date

  def initialize(habit:, habit_logs:)
    @habit = habit
    @habit_logs = habit_logs
  end

  # 集計
  def total_value
    habit_logs.sum(&:value_for_goal).to_i
  end

  def target_value
    habit.goal.amount.to_i
  end

  # 判定
  def achieved?
    case habit.goal.goal_unit
    when "check_based"
      habit_logs.any?
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
end
