FactoryBot.define do
  factory :habit_log do
    association :user
    association :habit
    started_at { Time.current }
    performed_value { 1 }
    goal { build(:goal, user: user, habit: habit) }

    trait :with_ended_at do
      ended_at { started_at + 1.hour }
    end
  end
end
