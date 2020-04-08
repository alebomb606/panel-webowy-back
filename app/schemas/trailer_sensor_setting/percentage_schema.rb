class TrailerSensorSetting::PercentageSchema < ParamSchema
  define! do
    required(:alarm_primary_value).filled(:int?)
    required(:warning_primary_value).filled(:int?)

    rule(lteq?: %i[alarm_primary_value warning_primary_value]) do |alarm_primary_value, warning_primary_value|
      alarm_primary_value.lteq?(100) & warning_primary_value.lteq?(100)
    end

    rule(gteq?: %i[alarm_primary_value warning_primary_value]) do |alarm_primary_value, warning_primary_value|
      alarm_primary_value.gteq?(0) & warning_primary_value.gteq?(0)
    end
  end
end
