company_1 = ::Company.create(name: 'Super firma 1', email: 'super_firma_1@example.com', nip: '9999999999', city: 'Lodz', postal_code: '100-1000', street: 'Super Ulica 12')
company_2 = ::Company.create(name: 'Super firma 2', email: 'super_firma_2@example.com', nip: '8888888888', city: 'Lodz', postal_code: '100-1432', street: 'Super Ulica 15')
company_3 = ::Company.create(name: 'Super firma 3', email: 'super_firma_3@example.com', nip: '7777777777', city: 'Lodz', postal_code: '100-1234', street: 'Super Ulica 21')

master_admin = ::MasterAdmin.create(first_name: 'master', last_name: 'admin', phone_number: '123456789')
master_admin_auth = ::Auth.create(email: 'safeway@admin.com', password: 'lolopolo')
master_admin_auth.master_admin = master_admin
master_admin_auth.save
master_admin_auth.confirm

trailer_1 = company_1.trailers.create(
  make: 0,
  description: 'Fajna naczepa',
  device_installed_at: Time.current,
  device_serial_number: 'AZ13416',
  model: 'The Iron Knight 1:50',
  registration_number: 'AGP-3359',
  engine_running: false,
  banana_pi_token: 'safectl0f32d038'
)
trailer_1.create_plan
trailer_1.sensors.create(
  kind: 'safeway_battery',
  setting: TrailerSensorSetting.create(
    alarm_primary_value: 14,
    alarm_secondary_value: 17,
    warning_primary_value: 15,
    warning_secondary_value: 16,
    send_sms: false,
    send_email: false
  )
)

trailer_1.sensors.create(
  kind: 'trailer_temperature',
  setting: TrailerSensorSetting.create(
    alarm_primary_value: 14,
    alarm_secondary_value: 17,
    warning_primary_value: 15,
    warning_secondary_value: 16,
    send_sms: false,
    send_email: false
  )
)

trailer_1.sensors.create(
    kind: 'driver_panel_battery',
    setting: TrailerSensorSetting.create(
        alarm_primary_value: 10,
        alarm_secondary_value: 20,
        warning_primary_value: 30,
        warning_secondary_value: 40,
        send_sms: false,
        send_email: false
    )
)
trailer_1.sensors.create(
    kind: 'engine',
    setting: TrailerSensorSetting.create(
        alarm_primary_value: 0,
        alarm_secondary_value: 0,
        warning_primary_value: 1,
        warning_secondary_value: 1,
        send_sms: false,
        send_email: false
    )
)
trailer_1.sensors.create(
    kind: 'truck_battery',
    setting: TrailerSensorSetting.create(
        alarm_primary_value: 10,
        alarm_secondary_value: 20,
        warning_primary_value: 30,
        warning_secondary_value: 40,
        send_sms: false,
        send_email: false
    )
)


trailer_2 = company_2.trailers.create(
  make: 1,
  description: 'Ultra naczepa',
  device_installed_at: Time.current,
  device_serial_number: 'BS21s82',
  model: 'Nimbus 3000',
  registration_number: 'PGG-6213',
  engine_running: false
)

trailer_2.create_plan
trailer_2.sensors.create(
  kind: 'safeway_battery',
  setting: TrailerSensorSetting.create(
    alarm_primary_value: 14,
    alarm_secondary_value: 17,
    warning_primary_value: 15,
    warning_secondary_value: 16,
    send_sms: false,
    send_email: false
  )
)
trailer_2.sensors.create(
  kind: 'trailer_temperature',
  setting: TrailerSensorSetting.create(
    alarm_primary_value: 14,
    alarm_secondary_value: 17,
    warning_primary_value: 15,
    warning_secondary_value: 16,
    send_sms: false,
    send_email: false
  )
)

logistician_1  = company_1.logisticians.create
logistician_1.create_person(email: 'logistician_1@example.com', company: company_1, first_name: 'Jan', last_name: 'Kowalski', phone_number: '+48555000111')
logistician_1.create_auth(email: 'logistician_1@example.com', password: 'logistician_1').confirm

logistician_2  = company_1.logisticians.create
logistician_2.create_person(email: 'logistician_2@example.com', company: company_1, first_name: 'Marcin', last_name: 'Gortat', phone_number: '+48555000001')
logistician_2.create_auth(email: 'logistician_2@example.com', password: 'logistician_2').confirm

logistician_3  = company_1.logisticians.create
logistician_3.create_person(email: 'logistician_3@example.com', company: company_1, first_name: 'Anna', last_name: 'Nowak', phone_number: '+48555000112')
logistician_3.create_auth(email: 'logistician_3@example.com', password: 'logistician_3').confirm

logistician_4  = company_2.logisticians.create
logistician_4.create_person(email: 'logistician_4@example.com', company: company_2, first_name: 'Wiktoria', last_name: 'Jóźwiak', phone_number: '+48555000113')
logistician_4.create_auth(email: 'logistician_4@example.com', password: 'logistician_4').confirm

logistician_5  = company_2.logisticians.create
logistician_5.create_person(email: 'logistician_5@example.com', company: company_2, first_name: 'Janusz', last_name: 'Tracz', phone_number: '+48555000114')
logistician_5.create_auth(email: 'logistician_5@example.com', password: 'logistician_5').confirm

logistician_6  = company_3.logisticians.create
logistician_6.create_person(email: 'logistician_6@example.com', company: company_3, first_name: 'Rust', last_name: 'Cohle', phone_number: '+48555000115')
logistician_6.create_auth(email: 'logistician_6@example.com', password: 'logistician_6').confirm

logistician_7  = company_3.logisticians.create
logistician_7.create_person(email: 'logistician_7@example.com', company: company_3, first_name: 'Maggie', last_name: 'Hart', phone_number: '+48555000116')
logistician_7.create_auth(email: 'logistician_7@example.com', password: 'logistician_7').confirm

access_perm_1 = ::TrailerAccessPermission.create(logistician: logistician_1, trailer: trailer_1, alarm_control: true, system_arm_control: true, load_in_mode_control: true, route_access: true, current_position: true, alarm_resolve_control: true, photo_download: true, video_download: true, monitoring_access: true, event_log_access: true, sensor_access: true)
access_perm_1 = ::TrailerAccessPermission.create(logistician: logistician_1, trailer: trailer_2, alarm_control: true, system_arm_control: true, load_in_mode_control: true, route_access: true, current_position: true, alarm_resolve_control: true, photo_download: true, video_download: true, monitoring_access: true, event_log_access: true, sensor_access: true)

TrailerDataUsageSync.create(last_sync_at: Time.current-10.days, updated_trailers: 0)
