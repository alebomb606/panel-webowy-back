class TrailerSensorSettingSerializer < ApplicationSerializer
  attributes :alarm_primary_value, :alarm_secondary_value,
    :warning_primary_value, :warning_secondary_value,
    :send_sms, :send_email, :phone_numbers, :email_addresses

  belongs_to :sensor,
    serializer: ::TrailerSensorSerializer,
    id_method_name: :trailer_sensor_id,
    record_type: :trailer_sensor
end
