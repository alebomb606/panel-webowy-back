class Api::Safeway::TrailerSensor::LogFormattedReading
  def initialize(sensor, sensor_values)
    @sensor    = sensor
    @value     = sensor_values[:value]
    @max_value = sensor_values[:max_value]
  end

  def call
    initialize_reading
    format_reading
    refresh_sensor_state
    @reading.save
    @reading
  end

  private

  def initialize_reading
    @reading = @sensor.readings.new(
      read_at: Time.current,
      original_value: @value,
      maximum_value: @max_value
    )
  end

  def format_reading
    formatted_reading = ::TrailerSensorReading::Formatter.new(@reading)
    @reading.value = formatted_reading.value
    @reading.value_percentage = formatted_reading.percentage
    @reading.status = formatted_reading.status
  end

  def refresh_sensor_state
    @sensor.update(
      value: @reading.value,
      value_percentage: @reading.value_percentage,
      status: @reading.status
    )
  end
end
