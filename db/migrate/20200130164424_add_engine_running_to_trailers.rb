class AddEngineRunningToTrailers < ActiveRecord::Migration[5.2]
  def change
    add_column :trailers, :engine_running, :boolean, :default => 'false'
    add_column :trailers, :network_available, :boolean, :default => 'false'
  end
end
