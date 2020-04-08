class TrailerEvent < ApplicationRecord
  KINDS = {
    start_loading: 0,
    end_loading: 1,
    alarm: 2,
    alarm_silenced: 3,
    alarm_off: 4,
    armed: 5,
    disarmed: 6,
    warning: 7,
    emergency_call: 8,
    quiet_alarm: 9,
    alarm_resolved: 10,
    truck_disconnected: 11,   # ADDED https://www.wrike.com/open.htm?id=450195737
    truck_connected: 12,      #
    shutdown_pending: 13,     #
    shutdown_immediate: 14,   #
    truck_battery_low: 15,    #
    truck_battery_normal: 16, # END
    engine_off: 17,           # ADDED https://www.wrike.com/open.htm?id=461324545
    engine_on: 18,            # END
    parking_on: 19,
    parking_off: 20
  }.freeze

  reverse_geocoded_by :latitude, :longitude

  belongs_to :trailer
  belongs_to :sensor_reading,
    class_name: 'TrailerSensorReading',
    foreign_key: :trailer_sensor_reading_id,
    optional: true
  has_one :route_log, dependent: :destroy
  belongs_to :logistician, optional: true
  belongs_to :linked_event, class_name: 'TrailerEvent', foreign_key: :linked_event_id, optional: true
  has_many :interactions, class_name: 'TrailerEvent', foreign_key: :linked_event_id, dependent: :destroy

  enum kind: KINDS
  scope :after, ->(date) { where('triggered_at > ?', date) }
end
