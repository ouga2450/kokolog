class HabitLogQuery
  def initialize(user:)
    @user = user
  end

  def base
    HabitLog.where(user: @user)
  end

  def today_logs
    base.for_today
  end

  def count_for_today
    today_logs.count
  end

  # 特定の習慣に紐づくHabitLogを取得
  def habit_logs(habit)
    base.for_habit(habit.id)
  end
end
