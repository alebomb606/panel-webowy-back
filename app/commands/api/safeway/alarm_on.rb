class Api::Safeway::AlarmOn
  def self.call(trailer)
    ::TrailerConnection::SendData.new(trailer).call(
      alarm: true
    )
  end
end
