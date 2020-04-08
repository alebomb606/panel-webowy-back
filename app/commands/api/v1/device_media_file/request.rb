class Api::V1::DeviceMediaFile::Request < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:auth).filled
    required(:trailer_id).filled(:int?)
    required(:requested_at).filled(:time?)
    required(:requested_time).filled(:date_time?)
    required(:kind).filled(included_in?: ::DeviceMediaFile.kinds.keys)
    required(:camera).filled(included_in?: ::DeviceMediaFile.cameras.keys)
  end

  def call(params)
    attributes = yield validate(params.to_h)
    permission = yield find_permission(attributes)
    trailer    = yield verify_trailer_permission(permission, attributes[:kind])
    yield verify_trailer_connected(trailer)
    attributes = assign_status(attributes)
    attributes = assign_uuid(attributes)
    media_file = create_media_file(attributes)
    yield request_media_from_device(trailer, attributes)
    broadcast_media_to_logistician(media_file)
    schedule_check_if_processed(media_file)

    Success(media_file)
  end

  private

  def schedule_check_if_processed(media_file)
    case media_file.kind
    when 'photo'
      ::Media::CheckIfProcessedWorker.perform_at(
        Rails.application.secrets.device_media_file[:check_photo_status_after_n_sec].seconds.from_now,
        media_id: media_file.id
      )
    when 'video'
      ::Media::CheckIfProcessedWorker.perform_at(
        Rails.application.secrets.device_media_file[:check_video_status_after_n_sec].seconds.from_now,
        media_id: media_file.id
      )
    end
  end

  def validate(params)
    validation = Schema.call(params)
    return Failure(errors: validation.errors) if validation.failure?

    Success(validation.output)
  end

  def assign_status(attributes)
    attributes.merge(status: 'request')
  end

  def assign_uuid(attributes)
    attributes.merge(uuid: SecureRandom.uuid)
  end

  def request_media_from_device(trailer, attributes)
    Try(TrailerConnection::SendData::SendDataFailed) { ::Api::Safeway::RequestMedia.call(trailer, attributes) }
      .or { Failure(what: :send_data_failed) }
  end

  def broadcast_media_to_logistician(media_file)
    ::Api::V1::DeviceMediaFile::Broadcast.call(media_file)
  end

  def verify_trailer_permission(permission, media_kind)
    return Failure(what: :no_permission) unless ::DeviceMediaFile::RequestPolicy.permitted?(permission, media_kind)

    Success(permission.trailer)
  end

  def verify_trailer_connected(trailer)
    return Failure(what: :trailer_not_connected) unless trailer.channel_uuid

    Success()
  end

  def find_permission(attributes)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(
      attributes[:auth],
      attributes[:trailer_id]
    )
  end

  def create_media_file(attributes)
    logistician = attributes[:auth].logistician
    logistician.device_media_files.create(attributes.except(:auth))
  end
end
