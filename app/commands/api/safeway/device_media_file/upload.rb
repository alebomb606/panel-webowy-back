class Api::Safeway::DeviceMediaFile::Upload < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      def valid_file_type?(value)
        MediaFileUploader.new.extension_whitelist.include?(File.extname(value.path).delete('.'))
      end
    end

    required(:file).filled(:valid_file_type?)
    required(:latitude).filled(:decimal?, :latitude?)
    required(:longitude).filled(:decimal?, :longitude?)
    required(:uuid).filled(:str?)
    required(:taken_at).filled(:date_time?)
  end

  def call(params)
    attributes = yield validate(params.to_h)
    device_media_file = yield fetch_media_file(attributes[:uuid])
    log_position(device_media_file, attributes[:latitude], attributes[:longitude])
    upload_media(device_media_file, attributes[:file], attributes[:taken_at])
    Success(device_media_file)
  end

  private

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

  def upload_media(media_file, file, taken_at)
    media_file.update(status: :processing, taken_at: taken_at)
    ::Media::UploadWorker.new.perform(media_file.id, file.path)
  end

  def broadcast_media_to_logistician(media_file)
    ::Api::V1::DeviceMediaFile::Broadcast.call(media_file)
  end
end
