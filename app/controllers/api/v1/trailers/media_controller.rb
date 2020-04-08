class Api::V1::Trailers::MediaController < Api::BaseController
  deserializable_resource :media_request, only: :request_media

  def index
    query = ::Api::V1::Trailers::Media::FilterQuery.new
    query.call(filter_params.merge(auth: current_auth)) do |m|
      m.success do |res|
        paginated = paginate(res)
        render json: ::TrailerMediaSerializer.new(
          paginated,
          links: pagination_links(paginated)
        )
      end

      m.failure(:trailer_not_found) do
        render json: ::ErrorSerializer.not_found('Trailer'), status: :not_found
      end

      m.failure(:no_permission) do
        head :forbidden
      end

      m.failure do |res|
        render json: ::ErrorSerializer.wrap(res[:errors]), status: :unprocessable_entity
      end
    end
  end

  def request_media
    ::Api::V1::DeviceMediaFile::Request.new.call(media_request_params) do |m|
      m.success do |res|
        render json: ::TrailerMediaSerializer.new(res), status: :created
      end

      m.failure(:trailer_not_found) do
        render json: ::ErrorSerializer.not_found('Trailer'), status: :not_found
      end

      m.failure(:trailer_not_connected) do
        render json: ::ErrorSerializer.not_connected, status: :unprocessable_entity
      end

      m.failure(:no_permission) do
        head :forbidden
      end

      m.failure do |res|
        render json: ::ErrorSerializer.wrap(res[:errors]), status: :unprocessable_entity
      end
    end
  end

  private

  def media_request_params
    params.require(:media_request).permit(
      :requested_time,
      :kind,
      :camera
    ).merge(
      auth: current_auth,
      requested_at: Time.current,
      trailer_id: params[:trailer_id]
    )
  end

  def filter_params
    params.permit(:trailer_id, filter: %i[date_from date_to cameras kinds statuses])
  end
end
