class Habit < ApplicationRecord
  # --- 関連 ---
  belongs_to :user
  belongs_to :category
  has_many :goals, dependent: :destroy
  has_many :habit_logs, dependent: :destroy

  # --- バリデーション ---
  validates :name, presence: true

  # --- スコープ ---
  # 有効な習慣を取得
  scope :active, -> { where(archived: false) }

  # 今日・今週・今月の目標取得
  scope :for_today, -> {
    joins(:goals)
    .merge(Goal.for_today)
    .distinct
  }

  scope :for_this_week, -> {
    joins(:goals)
    .merge(Goal.for_this_week)
    .distinct
  }

  scope :for_this_month, -> {
    joins(:goals)
    .merge(Goal.for_this_month)
    .distinct
  }

  # 実行済みの習慣か確認
  def executed_today?
  habit_logs.where(started_at: Time.zone.today.all_day).exists?
  end
end
