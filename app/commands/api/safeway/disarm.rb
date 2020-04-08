class Api::Safeway::Disarm
  def self.call(trailer)
    ::TrailerConnection::SendData.new(trailer).call(
      arm: false
    )
  end
end
