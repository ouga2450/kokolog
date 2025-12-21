class HabitProgressSummary
  def initialize(progresses)
    @progresses = progresses
  end

  def total
    progresses.size
  end

  def achieved_count
    progresses.count(&:achieved?)
  end

  def achievement_rate
    return nil if progresses.empty?

    avg = progresses.sum(&:progress_ratio) / total
    (avg * 100).round
  end

  private

  attr_reader :progresses
end
