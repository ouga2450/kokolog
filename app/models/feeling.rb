class Feeling < ApplicationRecord
  # --- 関連 ---
  has_many :mood_logs, dependent: :nullify

  # --- バリデーション ---
  validates :name, presence: true, uniqueness: true
end
