class CreateRouteLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :route_logs do |t|
      t.float :latitude
      t.float :longitude

      t.integer :trailer_id
      t.index :trailer_id

      t.datetime :sent_at
      t.timestamps
    end
  end
end
