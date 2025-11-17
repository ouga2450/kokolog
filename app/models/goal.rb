class Goal < ApplicationRecord
  # --- 関連 ---
  belongs_to :user
  belongs_to :habit

  # --- enum ---
  enum goal_type: { daily: 0, weekly: 1, monthly: 2 }
  enum status: { draft: 0, active: 1, achieved: 2 }
  enum target_type: { check_based: 0, count_based: 1, time_based: 2 }

  # --- バリデーション ---
  validates :goal_type, presence: true
  validates :status, presence: true
  validates :target_type, presence: true
  validate :start_date_must_be_before_end_date

  # --- 回数、時間目標の時のみ target_valueを必須にする ---
  validates :target_value,
    numericality: { greater_than: 0 },
    if: -> { target_type.in?([ "count_based", "time_based" ]) }

  # --- scope ---
  # activeかつdateが範囲内
  scope :effective_on, ->(date) {
    active
      .where("start_date IS NULL OR start_date <= ?", date)
      .where("end_date IS NULL OR end_date >= ?", date)
  }

  # 現在有効な目標
  scope :effective_today, -> {
    effective_on(Date.current)
  }

  # 今日・今週・今月の目標取得用スコープ
  scope :for_today, -> {
    daily.effective_today
  }

  scope :for_this_week, -> {
    weekly.effective_today
  }

  scope :for_this_month, -> {
    monthly.effective_today
  }

  # --- インスタンスメソッド ---
  # validate :start_dateがend_dateより前であること
  def start_date_must_be_before_end_date
    return if start_date.blank? || end_date.blank?

    if start_date > end_date
      errors.add(:start_date, "は終了日より前に設定してください")
    end
  end

  # 目標が特定の日に達成されているか？
  def achieved_on?(date)
    logs = habit_logs.where(started_at: date.all_day)
    logs.sum { |log| log.value_for_goal } >= target_value
  end
end
