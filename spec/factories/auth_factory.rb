FactoryBot.define do
  factory :auth do
    sequence :email do |n|
      "auth#{n}@example.com"
    end
    password { 'password1234' }

    after :create do |auth|
      auth.confirm
    end

    trait :with_logistician do
      after :create do |auth|
        create(:logistician, :with_person, auth: auth)
      end
    end
  end
end
