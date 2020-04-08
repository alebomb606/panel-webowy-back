class TrailerSensorSetting < ApplicationRecord
  belongs_to :sensor, class_name: 'TrailerSensor', foreign_key: :trailer_sensor_id

  def alarm_value_range
    alarm_primary_value..alarm_secondary_value
  end

  def warning_treshold_text
    return "#{warning_primary_value} - #{warning_secondary_value} #{sensor.value_unit}" if sensor.trailer_temperature?

    "#{warning_primary_value} #{sensor.value_unit}"
  end

  def changed_since?(date)
    updated_at > date
  end
end
