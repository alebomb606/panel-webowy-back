class Api::V1::Trailers::Sensors::Events::IndexQuery < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  def call(params)
    sensor = yield fetch_sensor(params)
    Success(sensor.events.order(triggered_at: :desc))
  end

  private

  def fetch_sensor(params)
    query = ::Api::V1::Trailers::Sensors::FetchQuery.new
    query.call(id: params[:sensor_id], auth: params[:auth])
  end
end
