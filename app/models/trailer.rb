class Trailer < ApplicationRecord
  MAKES = {
    wielton: 0,
    schmitz: 1,
    kogel: 2,
    wabash: 3,
    great_dane: 4,
    abc: 5
  }.freeze

  STATUSES = {
    start_loading: 0,
    end_loading: 1,
    alarm: 2,
    alarm_silenced: 3,
    alarm_off: 4,
    armed: 5,
    disarmed: 6,
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

  STATUSES_NAMES = STATUSES.keys.map(&:to_s).freeze
  INTERACTIONS = {
    'end_loading' => 'start_loading',
    'alarm_off' => %w[quiet_alarm emergency_call alarm],
    'alarm_silenced' => %w[quiet_alarm emergency_call alarm],
    'disarmed' => 'armed'
  }.freeze

  belongs_to :company,            optional: true
  has_many   :events,             class_name: 'TrailerEvent', foreign_key: :trailer_id, dependent: :destroy
  has_many   :access_permissions, class_name: 'TrailerAccessPermission', dependent: :destroy
  has_many   :logisticians,       through: :access_permissions
  has_one    :plan,               dependent: :destroy
  has_many   :route_logs,         dependent: :destroy
  has_many   :media_files,        class_name: 'DeviceMediaFile', foreign_key: :trailer_id, dependent: :destroy
  has_many   :sensors,            class_name: 'TrailerSensor', foreign_key: :trailer_id, dependent: :destroy
  has_many   :cameras,            class_name: 'TrailerCamera', foreign_key: :trailer_id, dependent: :destroy

  accepts_nested_attributes_for :plan

  enum make: MAKES
  enum status: STATUSES

  scope :active, -> { where(archived_at: nil) }

  def alarm_state?
    alarm? || alarm_silenced? || quiet_alarm? || emergency_call?
  end

  def self.makes_for_select_box
    makes.keys.map { |make| [make, make] }
  end

  def active?
    archived_at.nil?
  end

  def end_loading_possible_with?(status)
    loading_in_progress? && !status.to_s.in?(['end_loading', self.status])
  end

  def transformable_statuses
    return %w[alarm_silenced alarm_off emergency_call] - [status] if status.in?(%w[emergency_call alarm])
    return %w[alarm alarm_off emergency_call] if status.in?(%w[alarm_silenced quiet_alarm])
    return STATUSES_NAMES - INTERACTIONS.keys if status.in?(%w[end_loading alarm_off disarmed])

    STATUSES_NAMES - [status] - (INTERACTIONS.keys - [start_loading? ? 'end_loading' : 'disarmed'])
  end

  def loading_in_progress?
    events.start_loading.any? && events.end_loading.after(events.start_loading.maximum(:triggered_at)).empty?
  end

  def engine_on
    self.engine_running = true unless engine_running
    save
  end

  def engine_off
    self.engine_running = false if engine_running
    save
  end

  def hqtimezone
    company&.tz
  end
end
