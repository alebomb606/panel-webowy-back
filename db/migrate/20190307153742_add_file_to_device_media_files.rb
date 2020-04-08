class AddFileToDeviceMediaFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :device_media_files, :file, :string
  end
end
