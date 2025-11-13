class Habit < ApplicationRecord
  # --- 関連 ---
  belongs_to :user
  belongs_to :category
  has_many :goals, dependent: :destroy
  has_many :habit_logs, dependent: :destroy

  # --- バリデーション ---
  validates :name, presence: true

  # --- スコープ ---
  scope :active, -> { where(archived: false) }
end
