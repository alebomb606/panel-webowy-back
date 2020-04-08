class RenameEventsTriggeredByToSensorName < ActiveRecord::Migration[5.2]
  def change
    rename_column :trailer_events, :triggered_by, :sensor_name
  end
end
