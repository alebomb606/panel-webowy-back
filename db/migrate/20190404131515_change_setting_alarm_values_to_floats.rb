class ChangeSettingAlarmValuesToFloats < ActiveRecord::Migration[5.2]
  def up
    change_column :trailer_sensor_settings, :alarm_primary_value, :float
    change_column :trailer_sensor_settings, :alarm_secondary_value, :float
    change_column :trailer_sensor_settings, :warning_primary_value, :float
    change_column :trailer_sensor_settings, :warning_secondary_value, :float
  end

  def down
    change_column :trailer_sensor_settings, :alarm_primary_value, :integer
    change_column :trailer_sensor_settings, :alarm_secondary_value, :integer
    change_column :trailer_sensor_settings, :warning_primary_value, :integer
    change_column :trailer_sensor_settings, :warning_secondary_value, :integer
  end
end
