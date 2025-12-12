class Habit < ApplicationRecord
  include Hashid::Rails
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

  # 目標頻度ごとの習慣取得
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

  # 習慣ごとの記録を期間別に取得
  def logs_for(range:, date: Time.zone.today)
    case range
    when :daily
      habit_logs.where(started_at: date.all_day)
    when :weekly
      habit_logs.where(started_at: date.all_week)
    when :monthly
    habit_logs.where(started_at: date.all_month)
    else
      HabitLog.none
    end
  end

  # 実行済みの習慣か確認
  def executed_today?
  habit_logs.where(started_at: Time.zone.today.all_day).exists?
  end
end
