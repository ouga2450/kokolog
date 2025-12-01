class MoodLogQuery
  def initialize(user:)
    @user = user
  end

  def base
    MoodLog.where(user: @user)
  end

  def today_logs
    base.includes(:mood, :feeling).today.recent
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
end
