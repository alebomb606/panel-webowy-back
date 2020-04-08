class AddLatLngToTrailerEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :trailer_events, :latitude, :decimal, { precision: 10, scale: 6 }
    add_column :trailer_events, :longitude, :decimal, { precision: 10, scale: 6 }
  end
end
