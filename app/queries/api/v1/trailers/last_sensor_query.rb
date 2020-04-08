class Api::V1::Trailers::LastSensorQuery < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:auth).filled
    required(:trailer).filled
  end

  def call(params)
    attributes = yield validate(params)
    permission = yield find_permission(attributes)
    trailer    = yield verify_trailer_permission(permission)
    fetch_latest_reading(trailer)
  end

  private

  def find_permission(attributes)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(
      attributes[:auth],
      attributes[:trailer].id
    )
  end

  def verify_trailer_permission(permission)
    return Failure(what: :no_permission) unless permission.current_position?

    Success(permission.trailer)
  end

  def validate(params)
    validation = Schema.call(params)
    return Failure(errors: validation.errors) if validation.failure?

    Success(validation.output)
  end

  def fetch_latest_reading(trailer)
    return Failure(what: :no_sensors) if trailer.sensors.empty?

    Success(::Trailers::LastSensorQuery.call(trailer))
  end
end
