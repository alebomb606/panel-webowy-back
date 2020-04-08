class Trailer::UpdateStatusPolicy < ApplicationPolicy
  def initialize(permission, status)
    @permission = permission
    @status     = status
  end

  def call
    return @permission.alarm_control? if alarm_state?
    return @permission.system_arm_control? if system_arm_state?
    return @permission.load_in_mode_control? if load_in_state?

    @status.in?(::Trailer.statuses.keys)
  end

  private

  def alarm_state?
    @status.in?(%w[alarm alarm_silenced alarm_off quiet_alarm])
  end

  def system_arm_state?
    @status.in?(%w[armed disarmed])
  end

  def load_in_state?
    @status.in?(%w[start_loading end_loading])
  end
end
