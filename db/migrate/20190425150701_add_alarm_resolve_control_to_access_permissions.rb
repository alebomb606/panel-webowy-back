class AddAlarmResolveControlToAccessPermissions < ActiveRecord::Migration[5.2]
  def change
    add_column :trailer_access_permissions, :alarm_resolve_control, :boolean
  end
end
