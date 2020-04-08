class AddSpeedToRouteLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :route_logs, :speed, :decimal
  end
end
