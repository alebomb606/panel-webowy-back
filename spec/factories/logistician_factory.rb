FactoryBot.define do
  factory :logistician do
    archived_at        { nil }
    preferred_locale   { 'pl' }

    trait :with_auth do
      after :create do |logistician|
        create :auth, logistician: logistician
      end
    end

    trait :archived do
      archived_at { Time.current }
    end

    trait :with_person do
      after :create do |logistician|
        create :person, personifiable: logistician
      end
    end
  end
end
