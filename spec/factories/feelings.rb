FactoryBot.define do
  factory :feeling do
    sequence(:name) { |n| "name#{n}"  }
  end
end
