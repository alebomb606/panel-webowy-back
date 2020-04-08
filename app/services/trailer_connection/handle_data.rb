class TrailerConnection::HandleData
  attr_reader :data_handler
  ACTION_TYPES = %w[sensor_data event_data gps_data recording_list].freeze

  def initialize(current_trailer, data)
    @data_handler    = assign_proper_data_handler(data)
    @payload         = data['payload']
    @current_trailer = current_trailer
  end

  def call
    data_handler.new.call(@current_trailer, @payload) do |m|
      m.success do
        ::TrailerConnection::SendData.new(@current_trailer).call(handleData: 'success')
        BANANA_LOGGER.info('Payload handled succesfully.')
      end

      m.failure do |result|
        ::TrailerConnection::SendData.new(@current_trailer).call(handleData: 'failed')
        BANANA_LOGGER.error("Failed to handle data. Errors: #{result.to_json}")
      end
    end
  end

  private

  def assign_proper_data_handler(data)
    raise ChannelCommunicationError::UnsupportedActionType unless ACTION_TYPES.include? data.try(:[], 'action')

    case data['action']
    when 'sensor_data'
      ::Api::Safeway::TrailerSensorReading::LogFromWebsocket
    when 'event_data'
      ::Api::Safeway::TrailerEvent::LogFromWebsocket
    when 'recording_list'
      ::Api::Safeway::TrailerRecordingList::LogFromWebsocket
    when 'gps_data'
      ::Api::Safeway::RouteLog::LogFromWebsocket
    end
  end
end
