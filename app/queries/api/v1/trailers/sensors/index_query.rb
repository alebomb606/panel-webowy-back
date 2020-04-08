class Api::V1::Trailers::Sensors::IndexQuery < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:auth).filled
    required(:trailer_id).filled(:int?)
  end

  def call(params)
    attributes = yield validate(params.to_h)
    permission = yield find_permission(attributes)
    trailer    = yield verify_trailer_permission(permission)
    request_safeway_sensors(trailer)
    Success(trailer.sensors)
  end

  private

  def find_permission(attributes)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(
      attributes[:auth],
      attributes[:trailer_id]
    )
  end

  def verify_trailer_permission(permission)
    return Failure(what: :no_permission) unless permission.sensor_access?

    Success(permission.trailer)
  end

  def validate(params)
    validation = Schema.call(params)
    return Failure(errors: validation.errors) if validation.failure?

    Success(validation.output)
  end

  def request_safeway_sensors(trailer)
    ::Api::Safeway::RequestSensors.call(trailer)
  end
end
