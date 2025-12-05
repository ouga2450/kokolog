class Habit < ApplicationRecord
  # --- 関連 ---
  belongs_to :user
  belongs_to :category
  has_one :goal, dependent: :destroy
  has_many :habit_logs, dependent: :destroy

  # --- バリデーション ---
  validates :name, presence: true

  # --- スコープ ---
  # 有効な習慣を取得
  scope :active, -> { where(archived: false) }
  scope :recent, -> { order(recorded_at: :desc) }

  # 今日・今週・今月の目標取得
  scope :for_today, -> {
    joins(:goal)
    .merge(Goal.for_today)
    .distinct
  }

  scope :for_this_week, -> {
    joins(:goal)
    .merge(Goal.for_this_week)
    .distinct
  }

  scope :for_this_month, -> {
    joins(:goal)
    .merge(Goal.for_this_month)
    .distinct
  }

  # 目標との関連
  # 目標セット状態ごとの取得
  scope :draft, -> { joins(:goal).where(goals: { status: :draft }) }
  scope :active, -> { joins(:goal).where(goals: { status: :active }) }
  scope :achieved, -> { joins(:goal).where(goals: { status: :achieved }) }

  # 達成頻度ごとの取得
  scope :daily, -> { joins(:goal).where(goals: { frequency: :daily }) }
  scope :weekly, -> { joins(:goal).where(goals: { frequency: :weekly }) }
  scope :monthly, -> { joins(:goal).where(goals: { frequency: :monthly }) }

  # 実行済みの習慣か確認
  def executed_today?
  habit_logs.where(started_at: Time.zone.today.all_day).exists?
  end
end
