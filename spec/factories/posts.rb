FactoryBot.define do
  factory :post do
    body { Faker::Lorem.sentences.join(" ") }

    association :user, strategy: :build
  end
end
