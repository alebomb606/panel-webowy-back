class Media::CheckIfProcessedWorker
  include Sidekiq::Worker

  def perform(params = {})
    media = ::DeviceMediaFile.find(params['media_id'])
    return unless media.request?

    failure_params = { uuid: media.uuid, reason: 'Internal processing timeout.' }
    ::Integration::Nano::SubscriptionLost.new(media.trailer).call
    ::Api::Safeway::DeviceMediaFile::Failure.new.call(failure_params)
  rescue ActiveRecord::RecordNotFound
    UPLOAD_LOGGER.warn(
      "--- Check if media file processed failed. Media with id #{params['media_id']} was not found."
    )
  end
end
