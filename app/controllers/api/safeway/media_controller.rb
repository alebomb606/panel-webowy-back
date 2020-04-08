class Api::Safeway::MediaController < Api::Safeway::BaseController
  def upload
    ::Api::Safeway::DeviceMediaFile::Upload.new.call(update_media_params) do |m|
      m.success do
        head :ok
      end

      m.failure(:not_found) do
        head :not_found
      end

      m.failure do
        UPLOAD_LOGGER.warn "--- File upload failed for media with { uuid: #{update_media_params[:uuid]} }"
        head :unprocessable_entity
      end
    end
  end

  def failure
    ::Api::Safeway::DeviceMediaFile::Failure.new.call(failure_params) do |m|
      m.success do
        head :ok
      end

      m.failure(:not_found) do
        head :not_found
      end
    end
  end

  private

  def failure_params
    params.permit(:uuid, :reason)
  end

  def update_media_params
    params.permit(:uuid, :file, :latitude, :longitude, :taken_at)
  end
end
