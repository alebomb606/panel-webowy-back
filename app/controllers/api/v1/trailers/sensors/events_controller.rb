class Api::V1::Trailers::Sensors::EventsController < Api::BaseController
  def index
    query = ::Api::V1::Trailers::Sensors::Events::IndexQuery.new
    query.call(index_params) do |m|
      m.success do |events|
        paginated = paginate(events)
        render json: ::TrailerEventSerializer.new(paginated, include: %i[sensor_reading])
      end

      m.failure(:sensor_not_found) do
        render json: ::ErrorSerializer.not_found('TrailerSensor'), status: :not_found
      end

      m.failure(:trailer_not_found) do
        head :forbidden
      end

      m.failure(:no_permission) do
        head :forbidden
      end
    end
  end

  private

  def index_params
    params.permit(:sensor_id).merge(auth: current_auth)
  end
end
