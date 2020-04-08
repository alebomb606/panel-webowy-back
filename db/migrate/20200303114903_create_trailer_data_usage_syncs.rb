class CreateTrailerDataUsageSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :trailer_data_usage_syncs do |t|
      t.datetime :last_sync_at
      t.integer :updated_trailers
    end
  end
end
