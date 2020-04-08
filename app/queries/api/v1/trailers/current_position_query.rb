class Api::V1::Trailers::CurrentPositionQuery < AppCommand
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
    fetch_current_position(trailer)
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

  def fetch_current_position(trailer)
    return Failure(what: :no_routes) if trailer.route_logs.empty?

    Success(::Trailers::CurrentPositionQuery.call(trailer))
  end
end
