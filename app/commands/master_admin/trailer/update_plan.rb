class MasterAdmin::Trailer::UpdatePlan < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  module Types
    include Dry::Types.module
  end

  ArrayOfStrings = Types::Params::Array.of(Types::Coercible::String).constructor do |input|
    input.is_a?(Array) ? input.reject(&:blank?) : input
  end

  Schema = Dry::Validation.Params(::AppSchema) do
    configure { config.type_specs = true }

    required(:kind, :string).filled(:str?, included_in?: ::Plan.kinds.keys)
    required(:selected_features, ArrayOfStrings).filled do
      each { included_in?(::Plan.new.all_features.map(&:to_s)) }
    end
  end

  def call(trailer, params)
    attributes = yield validate(params)
    verify_kind(attributes)
    trailer.plan.update(attributes)
    Success(trailer)
  end

  private

  def validate(params)
    validation = Schema.call(params)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def verify_kind(attributes)
    attributes[:kind] = ::Plan.kind_for(attributes[:selected_features]) unless
      valid_features?(attributes)
  end

  def valid_features?(attributes)
    (attributes[:selected_features].sort == ::Plan.features_for(attributes[:kind]).sort)
  end
end
