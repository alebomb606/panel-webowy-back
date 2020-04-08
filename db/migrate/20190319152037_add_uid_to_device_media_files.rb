class AddUidToDeviceMediaFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :device_media_files, :uuid, :string
    add_index :device_media_files, :uuid
  end
end
