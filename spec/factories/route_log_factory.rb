FactoryBot.define do
  factory :route_log do
    longitude { Faker::Address.longitude }
    latitude { Faker::Address.latitude }
    speed { Faker::Number.positive }
    timestamp { DateTime.now }
    sent_at { DateTime.now }
  end
end
