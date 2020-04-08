class Api::Safeway::AcknowledgeEvent
  def self.call(trailer, uuid)
    action = 'acknowledge'
    ::TrailerConnection::SendData.new(trailer).call(
      action: action,
      uuid: uuid
    )
  end
end
