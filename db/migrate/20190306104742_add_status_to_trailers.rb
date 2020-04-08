class AddStatusToTrailers < ActiveRecord::Migration[5.2]
  def change
    add_column :trailers, :status, :integer
  end
end
