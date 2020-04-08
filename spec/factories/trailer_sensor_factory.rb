FactoryBot.define do
  factory :trailer_sensor do
    status  { ::TrailerSensor.statuses.keys.sample }
    kind    { ::TrailerSensor.kinds.keys.sample }
    value   { Faker::Number.number(2) }
    trailer

    trait :with_setting do
      after :create do |sensor|
        create(:trailer_sensor_setting, :with_secondary_values, sensor: sensor)
      end
    end
  end
end

