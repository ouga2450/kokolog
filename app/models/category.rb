class Category < ApplicationRecord
  has_many :habits, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :icon, length: { maximum: 10 }
  validates :description, length: { maximum: 200 }, allow_blank: true
end
