FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    name { "テストユーザー" }

    provider { nil }
    uid { nil }

    trait :google_linked do
      provider { "google_oauth2" }
      uid { SecureRandom.uuid }
      name { "Google User" }
    end
  end
end
