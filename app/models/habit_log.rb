class HabitLog < ApplicationRecord
  # --- 関連 ---
  belongs_to :user
  belongs_to :habit
  belongs_to :goal

  # before/after の MoodLog との関連付け
  has_many :mood_logs, dependent: :nullify

  # --- バリデーション ---
  validates :started_at, presence: true
  validates :performed_value,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # --- スコープ ---
  scope :for_today, -> { where(started_at: Time.zone.today.all_day) }
  scope :for_habit, ->(habit_id) { where(habit_id: habit_id) }
  scope :for_goal, ->(goal_id) { where(goal_id: goal_id) }

  # --- インスタンスメソッド ---
  # 実行時間（分）を計算するメソッド
  def duration_minutes
    return nil unless started_at && ended_at
    ((ended_at - started_at) / 60).floor
  end

  # 今日のログ？
  def today?
    started_at.to_date == Date.current
  end

  # check  → 常に 1
  # count  → performed_value（回数）
  # time   → performed_value（分）
  def value_for_goal
    case goal.target_type
    when "check"
      1
    else
      performed_value || 0
    end
  end

  # 今日の目標に対応する HabitLog か？
  # Home画面で「今日の実績」を色付けする時に便利
  def for_today_goal?
    goal.effective_today?
  end
end
