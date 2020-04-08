class MasterAdmin::TrailerSensor::MountAvailable
  def call(trailer)
    ::TrailerSensor.kinds.keys.each do |kind|
      sensor = trailer.sensors.find_or_create_by(kind: kind)
      assign_default_setting(sensor)
    end
  end

  private

  def assign_default_setting(sensor)
    return if sensor.setting.present?

    values = setting_values(sensor)
    sensor.create_setting(
      alarm_primary_value: values[:primary],
      alarm_secondary_value: values[:secondary],
      warning_primary_value: values[:primary],
      warning_secondary_value: values[:secondary],
      send_email: false,
      send_sms: false
    )
  end

  def setting_values(sensor)
    if sensor.trailer_temperature?
      return {
        primary: ::TrailerSensor::TEMPERATURE_RANGE.min,
        secondary: ::TrailerSensor::TEMPERATURE_RANGE.max
      }
    end

    { primary: 100, secondary: 100 }
  end
end
