class AddIndexToTrailerSensorReadings < ActiveRecord::Migration[5.2]
  def change
    add_index :trailer_sensor_readings, :read_at
    add_index :trailer_sensor_readings, [:trailer_sensor_id, :read_at]
  end
end
