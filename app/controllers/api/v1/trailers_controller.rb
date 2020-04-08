class Api::V1::TrailersController < Api::BaseController
  deserializable_resource :trailer, only: %i[update_status read_status]

  def index
    trailers = paginate(current_auth.logistician.trailers.active.order(id: :asc))
    render json: ::TrailerSerializer.new(
      trailers,
      links: pagination_links(trailers),
      params: { auth: current_auth },
      include: %i[access_permission]
    )
  end

  def show
    trailer = current_auth.logistician.trailers.active.find(params[:id])
    render json: ::TrailerSerializer.new(
      trailer,
      params: { auth: current_auth },
      include: %i[access_permission]
    )
  rescue ActiveRecord::RecordNotFound
    render json: ::ErrorSerializer.not_found('Trailer'), status: :not_found
  end

  def update_status
    update_status = ::Api::V1::Trailer::UpdateStatus.new
    update_status.call(update_status_params) do |m|
      m.success do |trailer|
        render json: ::TrailerSerializer.new(trailer, params: { auth: current_auth })
      end

      m.failure(:trailer_not_found) do
        render json: ::ErrorSerializer.not_found('Trailer'), status: :not_found
      end

      m.failure(:no_permission) do
        head :forbidden
      end

      m.failure do |result|
        render json: ::ErrorSerializer.wrap(result[:errors]), status: :unprocessable_entity
      end
    end
  end

  def read_status
    read_status = ::Api::V1::Trailer::ReadStatus.new
    read_status.call(read_status_params) do |m|
      m.success do |trailer|
        render json: ::TrailerSerializer.new(trailer, params: { auth: current_auth })
      end

      m.failure(:trailer_not_found) do
        render json: ::ErrorSerializer.not_found('Trailer'), status: :not_found
      end

      m.failure(:no_permission) do
        head :forbidden
      end

      m.failure do |result|
        render json: ::ErrorSerializer.wrap(result[:errors]), status: :unprocessable_entity
      end
    end
  end

  private

  def update_status_params
    params.require(:trailer).permit(:id, :status).merge(auth: current_auth)
  end

  def read_status_params
    params.require(:trailer).permit(:id, :status, :type).merge(auth: current_auth)
  end
end
