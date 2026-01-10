FactoryBot.define do
  factory :habit do
    association :user
    association :category
    sequence(:name) { |n| "Habit#{n}" }
    description { "description" }
    archived_at { nil }

    trait :archived do
      archived_at { Time.current }
    end
  end
end
