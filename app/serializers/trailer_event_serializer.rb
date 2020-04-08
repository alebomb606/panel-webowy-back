class TrailerEventSerializer < ApplicationSerializer
  attributes :kind, :sensor_name, :uuid

  attribute :triggered_at do |obj|
    obj.triggered_at&.iso8601
  end

  attribute :latitude do |obj|
    obj.route_log&.latitude
  end

  attribute :longitude do |obj|
    obj.route_log&.longitude
  end

  attribute :location_name do |obj|
    obj.route_log&.location_name
  end

  attribute :speed do |obj|
    obj.route_log&.speed
  end

  belongs_to :trailer,
    serializer: ::TrailerSerializer
  belongs_to :sensor_reading,
    serializer: ::TrailerSensorReadingSerializer,
    id_method_name: :trailer_sensor_reading_id,
    record_type: :trailer_sensor_reading
  belongs_to :logistician
  has_one :route_log, serializer: RouteLogSerializer
  has_many :interactions,
    serializer: ::InteractionSerializer
  belongs_to :linked_event,
    record_type: :trailer_event,
    id_method_name: :linked_event_id,
    serializer: self
end
