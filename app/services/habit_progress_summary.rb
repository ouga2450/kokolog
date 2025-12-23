class HabitProgressSummary
  attr_reader :progresses

  def initialize(progresses)
    @progresses = progresses
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
    return "" if progresses.empty?

    # progresses は同一 frequency / date で生成されているため
    # 全要素が同じ range を持つ
    range = progresses.first.range
    from = range.begin.to_date
    to   = range.end.to_date

    if from == to
      I18n.l(from, format: :long)
    else
      "#{I18n.l(from, format: :short)}〜#{I18n.l(to, format: :short)}"
    end
  end
end
