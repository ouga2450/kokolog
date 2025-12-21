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
  # 有効な行動を取得
  scope :discarded, -> { where.not(archived_at: nil) }
  scope :kept, -> { where(archived_at: nil) }
  scope :recent, -> { order(updated_at: :desc) }

  # 目標頻度ごとの行動取得
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
  # 達成頻度ごとの取得
  scope :with_draft_goal,    -> { joins(:goal).merge(Goal.draft) }
  scope :with_active_goal,   -> { joins(:goal).merge(Goal.active) }

  # 目標セット状態ごとの取得
  scope :daily, -> { joins(:goal).where(goals: { frequency: :daily }) }
  scope :weekly, -> { joins(:goal).where(goals: { frequency: :weekly }) }
  scope :monthly, -> { joins(:goal).where(goals: { frequency: :monthly }) }

  def archive!
    update!(archived_at: Time.current)
  end

  def restore!
    update!(archived_at: nil)
  end

  def archived?
    archived_at.present?
  end

  # 実行済みの行動か確認
  def executed_today?
  habit_logs.where(started_at: Time.zone.today.all_day).exists?
  end
end
