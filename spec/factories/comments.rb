FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.sentences.join(" ") }

    association :user, strategy: :build
    association :post, strategy: :build
  end
end
