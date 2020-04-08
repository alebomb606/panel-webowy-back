class Trailers::LastSensorQuery
  def self.call(trailer)
    trailer.sensors
      .joins(:readings)
      .select('"trailer_sensor_readings".*')
      .order('"trailer_sensor_readings"."read_at" DESC').first
  end
end
