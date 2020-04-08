class ChangeSensorSettingValues < ActiveRecord::Migration[5.2]
  def change
    add_column :trailer_sensor_settings, :alarm_primary_value, :integer
    add_column :trailer_sensor_settings, :alarm_secondary_value, :integer
    add_column :trailer_sensor_settings, :warning_primary_value, :integer
    add_column :trailer_sensor_settings, :warning_secondary_value, :integer
    add_column :trailer_sensor_settings, :send_sms, :boolean
    add_column :trailer_sensor_settings, :send_email, :boolean
    add_column :trailer_sensor_settings, :phone_numbers, :text, array: true, default: []
    add_column :trailer_sensor_settings, :email_addresses, :text, array: true, default: []

    remove_column :trailer_sensor_settings, :upper_treshold_value, :integer
    remove_column :trailer_sensor_settings, :lower_treshold_value, :integer
  end
end
