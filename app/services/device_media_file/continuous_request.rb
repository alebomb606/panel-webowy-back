class DeviceMediaFile::ContinuousRequest
  def initialize
    @trailers = fetch_active_trailers
  end

  def call
    request_media_from_trailers
  end

  private

  def fetch_active_trailers
    ::Trailer.includes(:cameras).active
  end

  def request_media_from_trailers
    @trailers.each do |trailer|
      installed_cameras = trailer.cameras.where.not(installed_at: nil)
      next if installed_cameras.blank?

      installed_cameras.order(:camera_type).each do |camera|
        attributes = build_attributes(camera)
        media_file = create_media_file(attributes)

        request = request_media_from_device(trailer, attributes)
        schedule_check_if_continuous_request_processed(media_file) if request
      end
    end
  end

  def build_attributes(camera)
    timestamp = Time.current
    {
      trailer_id: camera.trailer_id,
      requested_at: timestamp,
      requested_time: timestamp,
      kind: 'photo',
      camera: camera.camera_type,
      status: 'request',
      uuid: SecureRandom.uuid
    }
  end

  def create_media_file(attributes)
    ::DeviceMediaFile.create(attributes)
  end

  def request_media_from_device(trailer, attributes)
    ::Api::Safeway::RequestMedia.call(trailer, attributes)
    true
  rescue SendDataFailed
    MEDIA_CONTINUOUS_REQUEST_LOGGER.warn("Continuous requestMedia to trailer: #{trailer.id} failed.")
    ::Integration::Nano::SubscriptionLost.new(trailer).call
    false
  end

  def schedule_check_if_continuous_request_processed(media_file)
    ::Media::CheckIfContinuousRequestProcessedWorker.perform_at(
      Rails.application.secrets.device_media_file[:check_photo_status_after_n_sec].seconds.from_now,
      media_id: media_file.id
    )
  end
end
