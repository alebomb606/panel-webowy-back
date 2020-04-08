class CreateDrivers < ActiveRecord::Migration[5.2]
  def change
    create_table :drivers do |t|
      t.datetime :archived_at
      t.timestamps
    end
  end
end
