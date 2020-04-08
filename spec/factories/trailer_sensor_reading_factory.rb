FactoryBot.define do
  factory :trailer_sensor_reading do
    value            { Faker::Number.number(2) }
    value_percentage { value }
    original_value   { value }
    status           { ::TrailerSensorReading.statuses.keys.sample }
    read_at          { ::Faker::Time.between(10.hours.ago, Time.current) }
  end
end
