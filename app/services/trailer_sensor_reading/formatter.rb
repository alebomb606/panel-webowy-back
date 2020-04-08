class TrailerSensorReading::Formatter
  def initialize(reading)
    @reading = reading
    @sensor  = reading.sensor
    @setting = @sensor.setting
  end

  def status
    return range_status(value) if @sensor.trailer_temperature?
    return usage_status(value) if @sensor.data_transfer?
    return co2_status(value)   if @sensor.co2?
    return engine_status(value) if @sensor.engine?

    usage_status(percentage)
  end

  def percentage
    @percentage ||= normalized_percentage(value_percentage)
  end

  def value
    return [@reading.maximum_value - original_value, 0].max.round(2) if
      @sensor.data_transfer?

    original_value
  end

  def original_value
    @original_value ||= @reading.original_value&.round(2)
  end

  private

  def value_percentage
    return ::RangePercentageCalculator.call(value, @setting.alarm_value_range) if
      @sensor.trailer_temperature?
    return ::PercentageCalculator.call(value, @reading.maximum_value) if
      @sensor.data_transfer?

    value
  end

  def range_status(value)
    return :alarm   if value < @setting.alarm_primary_value ||
                       value > @setting.alarm_secondary_value
    return :warning if value < @setting.warning_primary_value ||
                       value > @setting.warning_secondary_value

    :ok
  end

  def usage_status(value)
    return :alarm   if value < @setting.alarm_primary_value
    return :warning if value < @setting.warning_primary_value

    :ok
  end

  def co2_status(value)
    return :alarm   if value > @setting.alarm_primary_value
    return :warning if value > @setting.warning_primary_value

    :ok
  end

  def normalized_percentage(percentage)
    return 100 if percentage > 100
    return 0   if percentage.negative?

    percentage
  end

  def engine_status(value)
    return :warning unless value
  end
end
