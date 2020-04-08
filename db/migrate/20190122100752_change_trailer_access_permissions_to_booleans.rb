class ChangeTrailerAccessPermissionsToBooleans < ActiveRecord::Migration[5.2]
  def change
    add_column :trailer_access_permissions, :alarm_control, :boolean, default: false
    add_column :trailer_access_permissions, :alarm_arm_control, :boolean, default: false
    add_column :trailer_access_permissions, :load_in_mode_control, :boolean, default: false

    add_column :trailer_access_permissions, :photo_download, :boolean, default: false
    add_column :trailer_access_permissions, :video_download, :boolean, default: false
    add_column :trailer_access_permissions, :live_photo, :boolean, default: false

    add_column :trailer_access_permissions, :current_position, :boolean, default: false
    add_column :trailer_access_permissions, :current_route, :boolean, default: false
    add_column :trailer_access_permissions, :historical_route, :boolean, default: false

    remove_column :trailer_access_permissions, :device_control
    remove_column :trailer_access_permissions, :monitoring_access
    remove_column :trailer_access_permissions, :map_access
  end
end
