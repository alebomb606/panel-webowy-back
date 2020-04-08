class AddDataUsageToTrailers < ActiveRecord::Migration[5.2]
  def change
    add_column :trailers, :data_usage, :jsonb, default: {}
  end
end
