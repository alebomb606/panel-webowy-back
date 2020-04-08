class ChangeTrailerSensorDataAttributes < ActiveRecord::Migration[5.2]
  def change
    remove_column :trailer_sensor_data, :tire_pressure_level, :string

    remove_column :trailer_sensor_data, :safeway_battery_level, :string
    remove_column :trailer_sensor_data, :trailer_temperature, :string
    remove_column :trailer_sensor_data, :driver_panel_battery_level, :string
    remove_column :trailer_sensor_data, :data_transfer_limit, :string
    remove_column :trailer_sensor_data, :co2_level, :string

    add_column :trailer_sensor_data, :safeway_battery_level, :integer
    add_column :trailer_sensor_data, :trailer_temperature, :integer
    add_column :trailer_sensor_data, :driver_panel_battery_level, :integer
    add_column :trailer_sensor_data, :data_transfer_used, :float
    add_column :trailer_sensor_data, :co2_level, :integer
    add_column :trailer_sensor_data, :read_at, :datetime
  end
end
