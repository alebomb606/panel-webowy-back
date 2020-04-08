FactoryBot.define do
  factory :person do
    first_name         { Faker::Name.first_name }
    last_name          { Faker::Name.last_name }
    phone_number       { Faker::Base.numerify("48#########") }
    extra_phone_number { Faker::Base.numerify("48#########") }
    email              { Faker::Internet.safe_email }

    trait :with_avatar do
      avatar { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/icon.jpg'), 'image/jpeg') }
    end

    trait :with_base64_avatar do
      avatar { "data:image/jpeg;base64,#{Base64.strict_encode64(File.read(Rails.root.join('spec/support/icon.jpg')))}" }
    end

    company
  end
end
