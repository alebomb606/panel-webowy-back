FactoryBot.define do
  factory :device_media_file do
    url            { Faker::Internet.url }
    requested_at   { Faker::Time.between(1.day.ago, Date.today, :day) }
    taken_at       { Faker::Time.between(1.day.ago, Date.today, :day) }
    kind           { 'photo' }
    status         { 'request' }
    camera         { DeviceMediaFile.cameras.keys.sample }
    requested_time { Faker::Time.between(1.day.ago, Date.today, :day).iso8601 }
    uuid           { SecureRandom.uuid }
    logistician    { create(:logistician, :with_auth, :with_person) }
    trailer
    trailer_event
    route_log

    trait :with_photo do
      file { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/icon.jpg'), 'image/jpeg') }
    end
  end
end
