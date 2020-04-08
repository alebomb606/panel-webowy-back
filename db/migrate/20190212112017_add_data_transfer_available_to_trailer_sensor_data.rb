class AddDataTransferAvailableToTrailerSensorData < ActiveRecord::Migration[5.2]
  def change
    add_column :trailer_sensor_data, :data_transfer_available, :float
  end
end
