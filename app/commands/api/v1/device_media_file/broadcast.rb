class Api::V1::DeviceMediaFile::Broadcast
  def self.call(media_file)
    return unless media_file.logistician # files uploaded by triggering alarm dont have a logistician reference

    ::Auth::EntityBroadcaster.new(
      entities: media_file,
      auth: media_file.logistician.auth,
      serializer: ::TrailerMediaSerializer
    ).call
  end
end
