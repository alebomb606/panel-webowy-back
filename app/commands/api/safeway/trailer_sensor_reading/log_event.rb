class Api::Safeway::TrailerSensorReading::LogEvent
  def initialize(reading)
    @reading = reading
    @trailer = reading.sensor.trailer
  end

  def call
    log_event
    log_position
    @event
  end

  private

  def log_event
    @event = ::TrailerEvent::LogInteraction.new(
      @trailer,
      kind: @reading.status,
      sensor_reading: @reading
    ).call
  end

  def log_position
    ::TrailerEvent::LogLatestPosition.call(@event)
  end
end
