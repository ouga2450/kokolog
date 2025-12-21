class HabitProgress
  def initialize(habit:, date: Time.zone.today, frequency: :daily)
    @habit = habit
    @date  = date
    @frequency = frequency
  end

  # 集計
  def total_value
    logs.sum(&:value_for_goal)
  end

  def target_value
    habit.goal.amount
  end

  # 判定
  def achieved?
    case habit.goal.goal_unit
    when "check_based"
      logs.exists?
    when "count_based", "time_based"
      logs.sum(:performed_value) >= habit.goal.amount
    else
      false
    end
  end

  def status
    return :not_applicable unless target_value.to_i.positive?

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


  private

  attr_reader :habit, :date, :frequency

  def logs
    habit.habit_logs.where(started_at: range_for_frequency)
  end

  # 頻度別に範囲分け
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
