class ApplicationCable::Connection < ActionCable::Connection::Base
  identified_by :current_trailer, :current_auth

  def connect
    if frontend_connection?
      self.current_auth = authorize_auth
    else
      self.current_trailer = find_verified_trailer
      current_trailer.update(channel_uuid: SecureRandom.uuid, subscribed_at: Time.current)
    end
  end

  def disconnect
    current_trailer&.update(subscribed_at: nil) # , channel_uuid: nil)
  end

  private

  def find_verified_trailer
    verified_trailer = Trailer.find_by(banana_pi_token: request.params[:token])
    verified_trailer.presence || reject_unauthorized_connection
  end

  def authorize_auth
    auth   = ::Auth.find_by(uid: request.params['uid'])
    token  = request.params['access-token']
    client = request.params['client']
    return reject_unauthorized_connection unless auth&.valid_token?(token, client)

    auth
  end

  def send_welcome_message
    if current_trailer
      transmit type: ActionCable::INTERNAL[:message_types][:welcome],
               message: current_trailer.channel_uuid,
               timezone: current_trailer.hqtimezone
    else
      transmit type: ActionCable::INTERNAL[:message_types][:welcome]
    end
  end

  def frontend_connection?
    request.params['connection_type'] == 'frontend'
  end
end
