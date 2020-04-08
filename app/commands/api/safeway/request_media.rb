class Api::Safeway::RequestMedia
  def self.call(trailer, attributes, alarm = false)
    ::TrailerConnection::SendData.new(trailer).call(
      url: media_upload_url(attributes[:uuid]),
      failure_url: failure_url(attributes[:uuid]),
      camera: attributes[:camera],
      time: attributes[:requested_time].to_i,
      kind: attributes[:kind],
      alarm: alarm
    )
  end

  def self.media_upload_url(uuid)
    "https://#{Rails.application.secrets.host}/api/safeway/media/#{uuid}/upload"
  end

  def self.failure_url(uuid)
    "https://#{Rails.application.secrets.host}/api/safeway/media/#{uuid}/failure"
  end
end
