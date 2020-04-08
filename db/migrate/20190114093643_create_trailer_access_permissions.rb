class CreateTrailerAccessPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :trailer_access_permissions do |t|
      t.integer :device_control, default: 0
      t.integer :monitoring_access, default: 0
      t.integer :map_access, default: 0

      t.boolean :sensor_access, default: false
      t.boolean :event_log_access, default: false

      t.belongs_to :logistician, foreign_key: true
      t.belongs_to :trailer, foreign_key: true

      t.timestamps
    end
  end
end
