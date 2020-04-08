class AddSensorDataReferenceToTrailerEvent < ActiveRecord::Migration[5.2]
  def change
    add_reference :trailer_events, :trailer_sensor_data, index: true
  end
end
