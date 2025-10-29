class Feeling < ApplicationRecord
  has_many :mood_logs, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
