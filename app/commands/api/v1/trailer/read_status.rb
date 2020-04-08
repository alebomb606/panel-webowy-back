class Api::V1::Trailer::ReadStatus < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:auth).filled
    required(:id).filled(:int?)
  end

  def call(params)
    attributes = yield validate(Schema, params)
    permission = yield find_permission(attributes)
    trailer    = yield verify_trailer_permission(permission)
    read_status(trailer)
    Success(trailer)
  end

  private

  def find_permission(attributes)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(
      attributes[:auth],
      attributes[:id]
    )
  end

  def validate(schema, params)
    validation = schema.call(params.to_h)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def verify_trailer_permission(permission)
    return Failure(what: :no_permission) unless ::Trailer::ReadStatusPolicy.permitted?(permission)

    Success(permission.trailer)
  end

  def read_status(trailer)
    ::Trailer::ReadStatus.new(
      trailer
    ).call
  end
end
