class CreateTrailers < ActiveRecord::Migration[5.2]
  def change
    create_table :trailers do |t|
      t.string :device_serial_number
      t.string :registration_number
      t.integer :make
      t.string :model
      t.text :description
      t.datetime :device_installed_at
      t.belongs_to(:company, foreign_key: true)

      t.timestamps
    end
  end
end
