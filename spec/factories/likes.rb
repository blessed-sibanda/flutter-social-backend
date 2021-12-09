FactoryBot.define do
  factory :like do
    association :user, strategy: :build
    association :likable, strategy: :build, factory: :post
  end
end
