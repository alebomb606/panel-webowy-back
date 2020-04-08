FactoryBot.define do
  factory :trailer_access_permission do
    alarm_control         { [true, false].sample }
    alarm_resolve_control { [true, false].sample }
    system_arm_control    { [true, false].sample }
    load_in_mode_control  { [true, false].sample }
    photo_download        { [true, false].sample }
    video_download        { [true, false].sample }
    monitoring_access     { [true, false].sample }
    current_position      { [true, false].sample }
    route_access          { [true, false].sample }
    sensor_access         { [true, false].sample }
    event_log_access      { [true, false].sample }
  end
end
