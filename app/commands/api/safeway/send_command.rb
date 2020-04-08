class Api::Safeway::SendCommand
  # rubocop:disable Metrics/CyclomaticComplexity

  def self.call(trailer, status)
    case status
    when 'alarm', 'emergency_call'
      ::Api::Safeway::AlarmOn.call(trailer)
    when 'alarm_silenced', 'alarm_off'
      ::Api::Safeway::AlarmOff.call(trailer)
    when 'armed'
      ::Api::Safeway::Arm.call(trailer)
    when 'disarmed'
      ::Api::Safeway::Disarm.call(trailer)
    when 'start_loading'
      ::Api::Safeway::StartLoading.call(trailer)
    when 'end_loading'
      ::Api::Safeway::EndLoading.call(trailer)
    end
  end

  # rubocop:enable Metrics/CyclomaticComplexity
end
