class TrailerAccessPermissionSerializer < ApplicationSerializer
  attributes :sensor_access, :event_log_access, :alarm_control, :alarm_resolve_control,
    :system_arm_control, :load_in_mode_control, :photo_download, :video_download,
    :monitoring_access, :current_position, :route_access
end
