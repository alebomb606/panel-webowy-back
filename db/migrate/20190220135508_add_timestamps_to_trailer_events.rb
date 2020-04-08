class AddTimestampsToTrailerEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :trailer_events, :created_at, :datetime
    add_column :trailer_events, :updated_at, :datetime
  end
end
