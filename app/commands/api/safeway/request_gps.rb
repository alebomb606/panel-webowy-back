class Api::Safeway::RequestGps
  def self.call(trailer)
    ::TrailerConnection::SendData.new(trailer).call(
      requestGPS: true
    )
  end
end
