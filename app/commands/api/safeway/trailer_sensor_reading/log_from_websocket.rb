class Api::Safeway::TrailerSensorReading::LogFromWebsocket < AppCommand
  include Dry::Monads::Do.for(:call, :process_sensors)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    optional(:truck_temperature).filled(:float?)
    optional(:battery).filled(:int?)
    optional(:driver_panel_battery_level).filled(:int?)
    optional(:data_available).filled(:float?)
    optional(:data_used).filled(:float?)
    optional(:co2).filled(:int?)
    optional(:truck_battery_level).filled(:int?)
    optional(:engine).filled(:int?)

    rule(filled?: %i[data_used data_available]) do |data_used, data_available|
      data_used.filled? > data_available.filled?
    end
  end

  def initialize
    @logged_readings = []
    @logged_events   = []
  end

  def call(trailer, params)
    @trailer = trailer
    yield process_sensors(params)
    update_trailer_status
    broadcast_modified_sensors_data
    Success(events: @logged_events, readings: @logged_readings)
  end

  private

  def process_sensors(params)
    params = yield validate(params)
    map_sensors(params).each do |sensor_values|
      sensor  = yield find_sensor(sensor_values[:name])
      reading = log_formatted_reading(sensor, sensor_values)
      process_reading(reading)
      if sensor.engine?
        if reading.value.positive?
          @trailer.engine_on
        else
          @trailer.engine_off
        end
      end
    end
    Success(params)
  end

  def process_reading(reading)
    notify_subscribers(reading)
    event = log_event(reading)
    @logged_events   << event if event.present?
    @logged_readings << reading
    reading
  end

  def log_formatted_reading(sensor, sensor_values)
    ::Api::Safeway::TrailerSensor::LogFormattedReading.new(sensor, sensor_values).call
  end

  def log_event(reading)
    ::Api::Safeway::TrailerSensorReading::LogEvent.new(reading).call
  end

  def notify_subscribers(reading)
    ::TrailerSensorReading::Notifier.new(reading).call
  end

  def update_trailer_status
    return if @trailer.reload.alarm?
    return unless @logged_events.any?(&:alarm?)

    ::Trailer::UpdateStatus.new(@trailer, 'alarm').call
  end

  def find_sensor(kind)
    Try(ActiveRecord::RecordNotFound) { @trailer.sensors.find_by!(kind: kind) }
      .or { Failure(what: :sensor_not_found) }
  end

  def validate(params)
    validation = Schema.call(params)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def broadcast_modified_sensors_data
    @trailer.logisticians.each do |logistician|
      ::Auth::EntityBroadcaster.new(
        entities: @logged_readings.map(&:sensor),
        auth: logistician.auth,
        serializer: ::TrailerSensorSerializer
      ).call
    end
  end

  def map_sensors(params)
    ::TrailerSensor::Mapper.call(params)
  end
end
