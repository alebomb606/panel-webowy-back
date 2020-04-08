class AddRecListToTrailers < ActiveRecord::Migration[5.2]
  def change
    add_column :trailers, :recording_list, :jsonb, default: {}
  end
end
