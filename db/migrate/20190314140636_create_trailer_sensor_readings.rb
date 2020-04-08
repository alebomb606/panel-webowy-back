class CreateTrailerSensorReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :trailer_sensor_readings do |t|
      t.belongs_to :trailer_sensor, foreign_key: true
      t.float :original_value
      t.float :maximum_value
      t.float :value
      t.integer :value_percentage
      t.integer :status
      t.datetime :read_at

      t.timestamps
    end

    drop_table :trailer_sensor_data do |t|
      t.string :trailer_temperature
      t.string :safeway_battery_level
      t.string :driver_panel_battery_level
      t.string :data_transfer_limit
      t.string :co2_level
      t.string :tire_pressure_level
      t.belongs_to :trailer, foreign_key: true
    end
  end
end
