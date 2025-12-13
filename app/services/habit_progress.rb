class HabitProgress
  def initialize(habit:, date: Time.zone.today)
    @habit = habit
    @date  = date
  end

  def total_value
    logs.sum(&:value_for_goal)
  end

  def target_value
    habit.goal.amount
  end

  def status
    return :not_applicable unless target_value

    rate = total_value.to_f / target_value

    case rate
    when 1.0.. then :achieved
    when 0.5...1.0 then :almost
    when 0.1...0.5 then :started
    else :none
    end
  end

  private

  attr_reader :habit, :date

  def logs
    habit.logs_for(
      range: habit.goal.frequency.to_sym,
      date: date
    )
  end
end
