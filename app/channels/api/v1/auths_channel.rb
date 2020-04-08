class Api::V1::AuthsChannel < ApplicationCable::Channel
  def subscribed
    stream_from("auths_#{current_auth.id}")
  end
end
