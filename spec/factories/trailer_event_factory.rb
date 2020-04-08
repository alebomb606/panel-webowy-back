FactoryBot.define do
  factory :trailer_event do
    kind         { ::TrailerEvent.kinds.keys.sample }
    triggered_at { Faker::Time.between(1.year.ago, Date.today, :day) }
    sensor_name  { 'CO2' }
    uuid         { SecureRandom.uuid }
    logistician  { create(:logistician, :with_person) }
    trailer
    route_log
  end
end
