FactoryBot.define do
  factory :company do
    name        { Faker::Company.name }
    email       { Faker::Internet.safe_email }
    nip         { Faker::Company.polish_taxpayer_identification_number }
    city        { Faker::Address.city }
    street      { Faker::Address.street_name }
    postal_code { Faker::Address.postcode }
    archived_at { nil }

    trait :archived do
      archived_at { Time.current }
    end
  end
end
