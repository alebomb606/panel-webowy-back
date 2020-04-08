class Api::V1::Trailers::RouteLogsController < Api::BaseController
  def index
    query = ::Api::V1::Trailers::RouteLogs::FilterQuery.new
    query.call(filter_params) do |m|
      m.success do |logs|
        render json: ::RouteLogSerializer.new(logs)
        fresh_when(logs.to_a, public: true)
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

  def filter_params
    params.permit(:trailer_id, filter: %i[date_from date_to]).merge(auth: current_auth)
  end
end
