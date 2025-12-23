class HabitQuery
  def initialize(user:, date: Date.current)
    @user = user
    @date = date
  end

  def base
    Habit.where(user: @user)
  end

  def active_base
    base.where(archived_at: nil)
        .joins(:goal)
        .merge(Goal.active.effective_on(@date))
        .distinct
  end

  # Goal（daily/weekly/monthly）に応じた対象行動
  # Home のタブ切り替えに使う
  def habits_for(tab)
    scope = active_base

    case tab.to_s
    when "today"
      scope.merge(Goal.daily)
    when "this_week"
      scope.merge(Goal.weekly)
    when "this_month"
      scope.merge(Goal.monthly)
    else
      raise ArgumentError, "Unknown tab: #{tab}"
    end
  end

  # 件数（空カードの判定用）
  def count_for(tab)
    habits_for(tab).count
  end

  def exists_for?(tab)
    count_for(tab).positive?
  end

  def none_for?(tab)
    count_for(tab).zero?
  end
end
