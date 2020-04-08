class Api::V1::TrailerSensorSetting::Apply < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  def call(params)
    attributes   = yield validate(::TrailerSensorSetting::BaseSchema, params)
    setting      = yield find_setting(attributes[:id])
    permission   = yield find_permission(attributes[:auth], setting)
    yield verify_trailer_permission(permission)
    alarm_values = yield validate(sensor_specific_schema(setting.sensor), attributes)
    attributes   = sanitized_attributes(alarm_values, attributes)
    setting.update(attributes)
    refresh_sensor_state(setting.sensor)
    Success(setting)
  end

  private

  def find_setting(id)
    Try(ActiveRecord::RecordNotFound) { ::TrailerSensorSetting.find(id) }
      .or { Failure(what: :setting_not_found) }
  end

  def find_permission(auth, setting)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(auth, setting.sensor.trailer)
  end

  def verify_trailer_permission(permission)
    return Failure(what: :no_permission) unless permission.sensor_access?

    Success(permission.trailer)
  end

  def validate(schema, params)
    validation = schema.new.call(params.to_h)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def sensor_specific_schema(sensor)
    return ::TrailerSensorSetting::TemperatureSchema if sensor.trailer_temperature?
    return ::TrailerSensorSetting::DataTransferSchema if sensor.data_transfer?

    ::TrailerSensorSetting::PercentageSchema
  end

  def sanitized_attributes(alarm_values, attributes)
    alarm_values.merge(
      send_sms: attributes[:send_sms],
      send_email: attributes[:send_email],
      phone_numbers: attributes[:phone_numbers],
      email_addresses: attributes[:email_addresses]
    )
  end

  def refresh_sensor_state(sensor)
    return if sensor.readings.empty?

    formatter = ::TrailerSensorReading::Formatter.new(sensor.readings.by_newest.first)
    sensor.update(
      status: formatter.status,
      value_percentage: formatter.percentage
    )
  end
end
