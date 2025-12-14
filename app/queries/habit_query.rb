class HabitQuery
  def initialize(user:)
    @user = user
  end

  def base
    Habit.where(user: @user)
  end

  def active_base
    base.where(archived_at: nil)
        .joins(:goal)
        .merge(Goal.active)
        .distinct
  end

  # Goal（daily/weekly/monthly）に応じた対象習慣
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
  # destroy / create / update 時に使用

  def count_for(tab)
    habits_for(tab).count
  end

  def exists_for?(tab)
    count_for(tab).positive?
  end

  # 0 件判定（UI に最も便利）

  def none_for?(tab)
    count_for(tab).zero?
  end
end
