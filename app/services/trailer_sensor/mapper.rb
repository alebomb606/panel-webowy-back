class TrailerSensor::Mapper
  SENSOR_NAMES_MAP = {
    'truck_temperature' => 'trailer_temperature',
    'battery' => 'safeway_battery',
    'driver_panel_battery_level' => 'driver_panel_battery',
    'co2' => 'co2',
    'truck_battery_level' => 'truck_battery',
    'data_used' => 'data_transfer',
    'engine' => 'engine'

  }.freeze

  def self.call(params)
    params.each_with_object([]) do |(k, v), memo|
      sensor_name = SENSOR_NAMES_MAP[k.to_s]
      next if sensor_name.blank?

      sensor_details = { name: sensor_name, value: v }
      sensor_details[:max_value] = params[:data_available] if sensor_name == 'data_transfer'
      memo << sensor_details
    end
  end
end
