class Goal < ApplicationRecord
  # --- 関連 ---
  belongs_to :user
  belongs_to :habit

  # --- enum ---
  enum goal_type: { daily: 0, weekly: 1, monthly: 2 }
  enum status: { draft: 0, active: 1, achieved: 2 }
  enum target_type: { check: 0, count: 1, time: 2 }

  # --- バリデーション ---
  validates :goal_type, presence: true
  validates :status, presence: true
  validates :target_type, presence: true

  # --- 回数、時間目標の時のみ target_valueを必須にする ---
  validates :target_value,
    numericality: { greater_than: 0 },
    if: -> { target_type.in?(["count", "time"]) }
end
