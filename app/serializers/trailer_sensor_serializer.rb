class TrailerSensorSerializer < ApplicationSerializer
  attributes :status, :value_percentage, :value, :kind

  has_one :setting, record_type: :trailer_sensor_setting, serializer: ::TrailerSensorSettingSerializer

  attribute :average_value do |obj|
    obj.readings.since_24h.average(:value).round(2).to_f
  end

  attribute :latest_read_at do |obj|
    obj.readings.by_newest.first&.read_at&.iso8601
  end
  attribute :trailer_id do |obj|
    obj.trailer.id
  end
end
