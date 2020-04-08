class Api::Safeway::DeviceMediaFile::Failure < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:uuid).filled(:str?)
    optional(:reason).filled(:str?)
  end

  def call(params)
    attributes = yield validate(params.to_h)
    device_media_file = yield fetch_media_file(attributes[:uuid])
    destroy(device_media_file)
    UPLOAD_LOGGER.warn(
      "--- File upload failed for media with { uuid: #{attributes[:uuid]} }
      with reason from device: #{attributes[:reason]}"
    )
    broadcast_media_to_logistician(device_media_file)
    Success(device_media_file)
  end

  private

  def destroy(media_file)
    media_file.destroy!
  end

  def validate(params)
    validation = Schema.call(params)
    return Failure(errors: validation.errors) if validation.failure?

    Success(validation.output)
  end

  def fetch_media_file(uuid)
    Try(ActiveRecord::RecordNotFound) { ::DeviceMediaFile.find_by!(uuid: uuid) }
      .or { Failure(what: :not_found) }
  end

  def log_position(media, lat, lng)
    params = {
      trailer_media_file_id: media.id,
      latitude: lat,
      longitude: lng
    }
    ::RouteLog::LogPositionForAssociation.call(params)
  end

  def broadcast_media_to_logistician(media_file)
    ::Api::V1::DeviceMediaFile::Broadcast.call(media_file)
  end
end
