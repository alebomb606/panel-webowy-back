class AddTimestampToRouteLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :route_logs, :timestamp, :float
  end
end
