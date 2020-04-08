class TrailerSensor < ApplicationRecord
  TEMPERATURE_RANGE = (-35..60).freeze
  STATUSES = { ok: 0, warning: 1, alarm: 2 }.freeze
  KINDS    = {
    data_transfer: 0,
    safeway_battery: 1,
    trailer_temperature: 2,
    driver_panel_battery: 3,
    co2: 4,
    truck_battery: 5,
    engine: 6,
    network: 7
  }.freeze

  belongs_to :trailer
  has_many   :readings, class_name: 'TrailerSensorReading', dependent: :destroy
  has_one    :setting, class_name: 'TrailerSensorSetting', dependent: :destroy
  has_many   :events, through: :readings, class_name: 'TrailerEvent', dependent: :destroy
  has_many   :warning_notifications, through: :readings, dependent: :destroy

  enum status: STATUSES
  enum kind:   KINDS

  def translated_kind
    I18n.t("activerecord.attributes.trailer_sensor.kinds.#{kind}")
  end

  def value_unit
    return 'GB' if data_transfer?
    return '°C' if trailer_temperature?

    '%'
  end
end
