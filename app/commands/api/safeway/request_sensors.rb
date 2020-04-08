class Api::Safeway::RequestSensors
  def self.call(trailer)
    ::TrailerConnection::SendData.new(trailer).call(
      requestSensors: true
    )
  end
end
