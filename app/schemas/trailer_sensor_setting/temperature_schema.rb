class TrailerSensorSetting::TemperatureSchema < ParamSchema
  # rubocop:disable Metrics/BlockLength

  define! do
    required(:alarm_primary_value).filled
    required(:alarm_secondary_value).filled
    required(:warning_primary_value).filled
    required(:warning_secondary_value).filled

    rule(gt?: %i[warning_primary_value alarm_primary_value]) do |warning_primary_value, alarm_primary_value|
      warning_primary_value.gt?(alarm_primary_value)
    end

    rule(lt?: %i[warning_secondary_value alarm_secondary_value]) do |warning_secondary_value, alarm_secondary_value|
      warning_secondary_value.lt?(alarm_secondary_value)
    end

    rule(gteq?: %i[alarm_primary_value]) do |alarm_primary_value|
      alarm_primary_value.gteq?(::TrailerSensor::TEMPERATURE_RANGE.min)
    end

    rule(lteq?: %i[alarm_secondary_value]) do |alarm_secondary_value|
      alarm_secondary_value.lteq?(::TrailerSensor::TEMPERATURE_RANGE.max)
    end

    rule(
      lt?: %i[
        alarm_primary_value alarm_secondary_value
      ]
    ) do |alarm_primary_value, alarm_secondary_value|
      alarm_primary_value.lt?(alarm_secondary_value)
    end

    rule(
      lt?: %i[
        warning_primary_value warning_secondary_value
      ]
    ) do |warning_primary_value, warning_secondary_value|
      warning_primary_value.lt?(warning_secondary_value)
    end
  end

  # rubocop:enable Metrics/BlockLength
end
