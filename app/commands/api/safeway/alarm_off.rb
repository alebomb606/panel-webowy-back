class Api::Safeway::AlarmOff
  def self.call(trailer)
    ::TrailerConnection::SendData.new(trailer).call(
      alarm: false
    )
  end
end
