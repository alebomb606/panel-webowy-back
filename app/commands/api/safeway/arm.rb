class Api::Safeway::Arm
  def self.call(trailer)
    ::TrailerConnection::SendData.new(trailer).call(
      arm: true
    )
  end
end
