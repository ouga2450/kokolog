class HabitProgressSummary
  attr_reader :progresses, :date, :frequency

  def initialize(progresses, date, frequency)
    @progresses = progresses
    @date       = date
    @frequency  = frequency
  end

  def total
    progresses.size
  end

  def achieved_count
    progresses.count(&:achieved?)
  end

  def logs
    progresses.flat_map(&:habit_logs)
  end

  def achievement_rate
    return nil if progresses.empty?

    avg = progresses.sum(&:progress_ratio) / total
    (avg * 100).round
  end

  def range_label
    range =
    case frequency.to_sym
    when :daily
      date.all_day
    when :weekly
      date.beginning_of_week..date.end_of_day
    when :monthly
      date.beginning_of_month..date.end_of_day
    else
      return ""
    end

    from = range.begin.to_date
    to   = range.end.to_date

    if from == to
      I18n.l(from, format: :short)
    else
      "#{I18n.l(from, format: :short)}〜#{I18n.l(to, format: :short)}"
    end
  end
end
