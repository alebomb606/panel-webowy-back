class CreateTrailerSensorData < ActiveRecord::Migration[5.2]
  def change
    create_table :trailer_sensor_data do |t|
      t.string :trailer_temperature
      t.string :safeway_battery_level
      t.string :driver_panel_battery_level
      t.string :data_transfer_limit
      t.string :co2_level
      t.string :tire_pressure_level
      t.belongs_to :trailer, foreign_key: true

      t.timestamps
    end
  end
end
