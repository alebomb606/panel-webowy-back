class CreateTrailerCameras < ActiveRecord::Migration[5.2]
  def change
    create_table :trailer_cameras do |t|
      t.belongs_to :trailer, foreign_key: true
      t.integer :camera_type
      t.datetime :installed_at
      t.datetime :updated_at
    end
  end
end
