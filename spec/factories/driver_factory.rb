FactoryBot.define do
  factory :driver do
    archived_at { nil }

    trait :archived do
      archived_at { Time.current }
    end

    after :create do |logistician|
      create :person, personifiable: logistician
    end
  end
end
