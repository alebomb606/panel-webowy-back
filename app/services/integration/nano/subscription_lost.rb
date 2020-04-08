class Integration::Nano::SubscriptionLost
  def initialize(trailer)
    @trailer = trailer
  end

  def call
    connection_status = ::TrailerConnection::SendData.new(@trailer).call(ping: 'pong')
    connection_status.zero? ? @trailer.update(subscribed_at: nil) : nil
  end
end
