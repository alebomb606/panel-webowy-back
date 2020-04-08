FactoryBot.define do
  factory :master_admin do
    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name }
    phone_number { Faker::Base.numerify("48#########") }
  end
end
