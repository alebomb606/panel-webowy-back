class Api::V1::Trailers::Sensors::FetchQuery < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:auth).filled
    required(:id).filled(:int?)
  end

  def call(params)
    attributes = yield validate(params.to_h)
    sensor     = yield find_sensor(attributes[:id])
    permission = yield find_access_permission(auth: attributes[:auth], trailer_id: sensor.trailer_id)
    trailer    = yield verify_trailer_permission(permission)
    request_safeway_sensors(trailer)
    Success(sensor)
  end

  private

  def validate(params)
    validation = Schema.call(params)
    return Failure(errors: validation.errors) if validation.failure?

    Success(validation.output)
  end

  def find_sensor(id)
    Try(ActiveRecord::RecordNotFound) { ::TrailerSensor.find(id) }
      .or { Failure(what: :sensor_not_found) }
  end

  def find_access_permission(attributes)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(
      attributes[:auth],
      attributes[:trailer_id]
    )
  end

  def verify_trailer_permission(permission)
    return Failure(what: :no_permission) unless permission.sensor_access?

    Success(permission.trailer)
  end

  def request_safeway_sensors(trailer)
    ::Api::Safeway::RequestSensors.call(trailer)
  end
end
