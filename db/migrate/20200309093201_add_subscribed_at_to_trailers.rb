class AddSubscribedAtToTrailers < ActiveRecord::Migration[5.2]
  def change
    add_column :trailers, :subscribed_at, :datetime
  end
end
