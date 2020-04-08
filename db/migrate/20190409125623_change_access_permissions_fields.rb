class ChangeAccessPermissionsFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :trailer_access_permissions, :historical_route, :boolean
    rename_column :trailer_access_permissions, :alarm_arm_control, :system_arm_control
    rename_column :trailer_access_permissions, :current_route, :route_access
    rename_column :trailer_access_permissions, :live_photo, :monitoring_access
  end
end
