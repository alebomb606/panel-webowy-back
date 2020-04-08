class AddTrailerSensorReferenceToSettings < ActiveRecord::Migration[5.2]
  def change
    remove_reference :trailer_sensor_settings, :trailer
    add_reference :trailer_sensor_settings, :trailer_sensor, foreign_key: true
    remove_column :trailer_sensor_settings, :sensor_kind, :integer
  end
end
