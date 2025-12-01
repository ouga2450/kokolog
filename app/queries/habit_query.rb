class HabitQuery
  def initialize(user:)
    @user = user
  end

  def base
    Habit.where(user: @user)
  end

  def active_base
    base.where(archived: false)
  end

  # Goal（daily/weekly/monthly）に応じた対象習慣
  # Home のタブ切り替えに使う

  def habits_for(tab)
    case tab.to_s
    when "today"      then active_base.joins(:goal).merge(Goal.daily).distinct
    when "this_week"  then active_base.joins(:goal).merge(Goal.weekly).distinct
    when "this_month" then active_base.joins(:goal).merge(Goal.monthly).distinct
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
