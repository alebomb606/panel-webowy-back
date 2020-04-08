class Api::Safeway::TrailerEvent::Log < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:trailer).filled
    required(:kind).filled(included_in?: ::TrailerEvent.kinds.keys)
    required(:triggered_at).filled(:time?)
    required(:uuid).filled(:str?)
    optional(:sensor_name).maybe(:str?)
  end

  def call(params)
    attributes = yield validate(params.to_h)
    Success(log_event(attributes))
  end

  private

  def validate(params)
    validation = Schema.call(params)
    return Failure(errors: validation.errors) if validation.failure?

    Success(validation.output)
  end

  def log_event(attributes)
    return if ::TrailerEvent.find_by(uuid: attributes[:uuid])

    ::TrailerEvent::LogInteraction.new(attributes[:trailer], attributes).call
  end
end
