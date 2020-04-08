class ReverseGeocoder
  def self.call(latitude:, longitude:, language:)
    result = Geocoder.search([latitude, longitude]).first
    {
      locale: language,
      location_name: [result&.city, result&.state, result&.country].compact.join(', ')
    }
  end
end
