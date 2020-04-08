class Api::Safeway::StartLoading
  def self.call(trailer)
    ::TrailerConnection::SendData.new(trailer).call(
      loading: true
    )
  end
end
