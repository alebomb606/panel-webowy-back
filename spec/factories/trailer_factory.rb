FactoryBot.define do
  factory :trailer do
    device_serial_number { ('A'..'Z').to_a.sample(2).join + Faker::Number.number(5) }
    registration_number  { Faker::Vehicle.license_plate }
    phone_number         { Faker::Base.numerify("48#########") }
    device_installed_at  { Faker::Time.between(1.year.ago, Date.today, :day) }
    make                 { ::Trailer.makes.keys.sample }
    model                { Faker::Vehicle.model }
    description          { Faker::Lorem.paragraph(3) }
    archived_at          { nil }
    banana_pi_token      { ::SecureRandom.uuid }
    channel_uuid         { ::SecureRandom.uuid }
    status               { ::Trailer.statuses.keys.sample }
    spedition_company    { Faker::Company.name }
    transport_company    { Faker::Company.name }
    engine_running       { false }
    company

    trait :archived do
      archived_at { Time.current }
    end

    trait :with_plan do
      after :create do |trailer|
        create(:plan, trailer: trailer)
      end
    end

    trait :with_permission do
      transient do
        permission_logistician { nil }
      end

      after :create do |trailer, evaluator|
        create(:trailer_access_permission,
          trailer: trailer,
          logistician: evaluator.permission_logistician,
          alarm_control: true,
          alarm_resolve_control: true,
          system_arm_control: true,
          load_in_mode_control: true,
          photo_download: true,
          video_download: true,
          monitoring_access: true,
          current_position: true,
          route_access: true,
          sensor_access: true,
          event_log_access: true
        )
      end
    end

    trait :with_sensor_settings do
      after :create do |trailer|
        ::TrailerSensorSetting.sensor_kinds.keys.each do |sk|
          create(:trailer_sensor_setting, sensor_kind: sk, trailer: trailer)
        end
      end
    end

    trait :with_cameras do
      after :create do |trailer|
        ::TrailerCamera.camera_types.keys.each do |ct|
          create(:trailer_camera, trailer_id: trailer.id, camera_type: ct)
        end
      end
    end

    trait :with_installed_cameras do
      after :create do |trailer|
        ::TrailerCamera.camera_types.keys.each do |ct|
          create(:trailer_camera, trailer_id: trailer.id, camera_type: ct, installed_at: Time.current)
        end
      end
    end
  end
end
