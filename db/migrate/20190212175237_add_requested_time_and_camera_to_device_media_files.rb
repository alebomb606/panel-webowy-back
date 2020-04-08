class AddRequestedTimeAndCameraToDeviceMediaFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :device_media_files, :requested_time, :datetime
    add_column :device_media_files, :camera, :integer
  end
end
