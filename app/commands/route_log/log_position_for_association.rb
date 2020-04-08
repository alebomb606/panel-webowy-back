class RouteLog::LogPositionForAssociation
  def self.call(params)
    attributes = reverse_geocode_position(params.to_h)
    create_route_log(attributes)
  end

  class << self
    private

    def reverse_geocode_position(attributes)
      attributes.merge(
        ReverseGeocoder.call(
          latitude: attributes[:latitude],
          longitude: attributes[:longitude],
          language: :en
        )
      )
    end

    def create_route_log(params)
      RouteLog.create(params)
    end
  end
end
