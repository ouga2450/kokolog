class Mood < ApplicationRecord
  # --- 関連 ---
  has_many :mood_logs, dependent: :nullify

  # --- バリデーション ---
  validates :score, presence: true, uniqueness: true
  validates :label, presence: true, uniqueness: true
  validates :color, presence: true
end
