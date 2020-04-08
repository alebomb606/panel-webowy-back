class RemoveLatitudeAndLongitudeFromTrailerEventsAndDeviceMediaFiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :trailer_events, :latitude, precision: 10, scale: 6
    remove_column :trailer_events, :longitude, precision: 10, scale: 6
    remove_column :device_media_files, :latitude, precision: 10, scale: 6
    remove_column :device_media_files, :longitude, precision: 10, scale: 6
  end
end
