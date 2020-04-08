class Api::Safeway::RequestEvents
  def self.call(trailer)
    ::TrailerConnection::SendData.new(trailer).call(
      requestEvents: true
    )
  end
end
