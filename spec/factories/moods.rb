FactoryBot.define do
  factory :mood do
    sequence(:score) { |n| n }
    sequence(:label) { |n| "Mood#{n}" }
    color { "#ffffff" }
  end
end
