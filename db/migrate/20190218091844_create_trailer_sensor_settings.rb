class CreateTrailerSensorSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :trailer_sensor_settings do |t|
      t.integer :sensor_kind
      t.integer :upper_treshold_value
      t.integer :lower_treshold_value

      t.belongs_to :trailer, foreign_key: true

      t.timestamps
    end
  end
end
