# 拡張用 現在未使用

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

  def exists_today?
    count_for_today.positive?
  end

  def none_today?
    count_for_today.zero?
  end

  # 特定の行動に紐づくHabitLogを取得
  def habit_logs(habit)
    base.for_habit(habit.id)
  end
end
