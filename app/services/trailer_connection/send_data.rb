class TrailerConnection::SendData
  def initialize(trailer)
    @trailer = trailer
  end

  def call(data)
    if data.key? 'camera' # FIXME: remove condition when frontend error handling fixed
      raise SendDataFailed, 'Trailer not connected' unless @trailer.channel_uuid
    end

    send_data(data)
  end

  class SendDataFailed < RuntimeError
  end

  private

  def send_data(data)
    broadcast = ActionCable.server.broadcast(
      "trailer_#{@trailer.channel_uuid}",
      data.merge(subscribed_at: @trailer.subscribed_at&.iso8601)
    )

    BANANA_LOGGER.info("
      #{friendly_status(broadcast)} broadcast to trailer: #{@trailer.id}, attr: #{data} #{channel_uuid(@trailer)}
    ")

    broadcast
  end

  def friendly_status(broadcast)
    return 'Failed' unless broadcast == 1

    'Successed'
  end

  def channel_uuid(trailer)
    return unless trailer.channel_uuid?

    ", channel_uuid: #{trailer.channel_uuid}"
  end
end
