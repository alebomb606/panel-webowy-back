class Api::V1::Trailer::UpdateStatus < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:auth).filled
    required(:id).filled(:int?)
    required(:status).filled(:str?, included_in?: ::Trailer.statuses.keys)
  end

  StatusSchema = Dry::Validation.Params(::AppSchema) do
    configure do
      option :statuses
      option :current_status
    end

    required(:status).filled

    rule(included_in?: %i[status]) do |status|
      status.included_in?(statuses)
    end

    rule(not_eql?: %i[status]) do |status|
      status.not_eql?(current_status)
    end
  end

  def call(params)
    attributes = yield validate(Schema, params)
    permission = yield find_permission(attributes)
    trailer    = yield verify_trailer_permission(permission, attributes[:status])
    yield validate_status(trailer, attributes)
    event = log_interaction(trailer, attributes)
    log_position(event)
    update_status(trailer, attributes)
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

  def validate_status(trailer, attributes)
    validate(
      StatusSchema.with(
        statuses: trailer.transformable_statuses,
        current_status: trailer.status
      ),
      attributes
    )
  end

  def verify_trailer_permission(permission, status)
    return Failure(what: :no_permission) unless ::Trailer::UpdateStatusPolicy.permitted?(permission, status)

    Success(permission.trailer)
  end

  def update_status(trailer, attributes)
    ::Trailer::UpdateStatus.new(
      trailer,
      attributes[:status]
    ).call
  end

  def log_interaction(trailer, attributes)
    ::TrailerEvent::LogInteraction.new(
      trailer,
      logistician: attributes[:auth].logistician,
      kind: attributes[:status]
    ).call
  end

  def log_position(event)
    ::TrailerEvent::LogLatestPosition.call(event)
  end
end
