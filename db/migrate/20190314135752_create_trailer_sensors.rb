class CreateTrailerSensors < ActiveRecord::Migration[5.2]
  def change
    create_table :trailer_sensors do |t|
      t.belongs_to :trailer, foreign_key: true
      t.float :value
      t.integer :value_percentage
      t.integer :status
      t.integer :kind

      t.timestamps
    end

    remove_reference :trailer_events, :trailer_sensor_data
    add_reference :trailer_events, :trailer_sensor_reading, index: true
  end
end
