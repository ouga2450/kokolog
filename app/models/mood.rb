class Mood < ApplicationRecord
    has_many :mood_logs, dependent: :nullify

  validates :score, presence: true, uniqueness: true
  validates :label, presence: true, uniqueness: true
  validates :color, presence: true
end
