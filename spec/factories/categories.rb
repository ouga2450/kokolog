FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category#{n}" }
    icon { "icon" }
    description { "description" }
  end
end
