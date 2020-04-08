class ChangeRouteLogLatLngToDecimal < ActiveRecord::Migration[5.2]
  def change
    change_column :route_logs, :longitude, :decimal, { precision: 10, scale: 6 }
    change_column :route_logs, :latitude, :decimal, { precision: 10, scale: 6 }
  end
end
