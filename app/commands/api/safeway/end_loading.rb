class Api::Safeway::EndLoading
  def self.call(trailer)
    ::TrailerConnection::SendData.new(trailer).call(
      loading: false
    )
  end
end
