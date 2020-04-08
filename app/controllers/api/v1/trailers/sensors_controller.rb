class Api::V1::Trailers::SensorsController < Api::BaseController
  def index
    query = ::Api::V1::Trailers::Sensors::IndexQuery.new
    query.call(index_params) do |m|
      m.success do |sensors|
        render json: ::TrailerSensorSerializer.new(sensors)
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

  def show
    query = ::Api::V1::Trailers::Sensors::FetchQuery.new
    query.call(show_params) do |m|
      m.success do |sensor|
        render json: ::TrailerSensorSerializer.new(sensor, include: %i[setting])
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
    params.permit(:trailer_id).merge(auth: current_auth)
  end

  def show_params
    params.permit(:id).merge(auth: current_auth)
  end
end
