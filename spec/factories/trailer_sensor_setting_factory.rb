FactoryBot.define do
  factory :trailer_sensor_setting do
    alarm_primary_value     { rand(10..30) }
    warning_primary_value   { alarm_primary_value + rand(2..15) }
    send_sms                { [true, false].sample }
    send_email              { [true, false].sample }
    phone_numbers           { Array.new(2) { Faker::Base.numerify("48#########") } if send_sms }
    email_addresses         { Array.new(2) { Faker::Internet.email } if send_email }

    trait :with_secondary_values do
      alarm_secondary_value   { warning_primary_value + rand(5..10) }
      warning_secondary_value { [alarm_secondary_value - rand(5..10), warning_primary_value].max }
    end
  end
end
