class RouteLogSerializer < ApplicationSerializer
  attributes :longitude, :latitude, :speed, :location_name

  attribute :sent_at do |obj|
    obj.sent_at&.iso8601
  end
end
