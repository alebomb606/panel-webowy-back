class TrailerSensorReading < ApplicationRecord
  STATUSES = { ok: 0, warning: 1, alarm: 2 }.freeze

  belongs_to :sensor, class_name: 'TrailerSensor', foreign_key: :trailer_sensor_id
  has_one    :event, class_name: 'TrailerEvent', dependent: :destroy
  has_one    :trailer, through: :sensor
  has_many   :warning_notifications, dependent: :destroy

  scope :since_24h, -> { where(read_at: 24.hours.ago..Time.current) }
  scope :by_newest, -> { order(read_at: :desc) }

  enum status: STATUSES

  def translated_status
    I18n.t("activerecord.attributes.trailer_sensor_reading.statuses.#{status}")
  end

  def value_text
    "#{value} #{sensor.value_unit}"
  end

  def notifiable?
    return false if ok?

    previous_reading = fetch_previous
    return true if previous_reading.nil?
    return true if sensor.setting.changed_since?(previous_reading.read_at)

    value != previous_reading.value && previous_reading.ok?
  end

  def event_triggerable?
    return false if ok?
    return false if trailer.alarm_state?

    previous_reading = fetch_previous
    return true if previous_reading.nil?

    previous_reading.ok? || (previous_reading.warning? && alarm?)
  end

  def fetch_previous
    sensor.readings.where.not(id: id).by_newest&.first
  end
end
