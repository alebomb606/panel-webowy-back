class TrailerSensorSetting::DataTransferSchema < ParamSchema
  define! do
    required(:alarm_primary_value).filled(:float?, gt?: 0)
    required(:warning_primary_value).filled(:float?, gt?: 0)

    rule(gteq?: %i[alarm_primary_value warning_primary_value]) do |alarm_primary_value, warning_primary_value|
      warning_primary_value.gteq?(alarm_primary_value)
    end
  end
end
