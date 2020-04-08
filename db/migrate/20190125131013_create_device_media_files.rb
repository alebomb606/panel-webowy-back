class CreateDeviceMediaFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :device_media_files do |t|
      t.references :trailer, foreign_key: true
      t.references :trailer_event, foreign_key: true
      t.references :logistician
      t.string :url, index: true
      t.datetime :requested_at
      t.datetime :taken_at
      t.integer :kind
      t.integer :status
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.timestamps
    end
  end
end
