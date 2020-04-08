class Api::V1::Trailers::Events::FilterQuery < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  module Types
    include Dry::Types.module

    EventKind = Types::String.constructor do |str|
      str ? str.gsub(/\s+/, '').split(',') : str
    end
  end

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      config.type_specs = true
    end

    required(:auth, Types.Constructor(Auth)).filled
    required(:trailer_id, :integer).filled(:int?)

    optional(:filter).schema do
      optional(:date_from, :date_time).filled(:date_time?)
      optional(:date_to, :date_time).filled(:date_time?)
      optional(:kinds, Types::EventKind).maybe(:array?) do
        each { included_in?(::TrailerEvent.kinds.keys) }
      end

      rule(from_before_to?: %i[date_from date_to]) do |date_from, date_to|
        date_from.filled? & date_to.filled? > date_from.lteq?(date_to)
      end
    end
  end

  def call(params)
    attributes = yield validate(params.to_h)
    permission = yield find_permission(attributes)
    trailer    = yield verify_trailer_permission(permission)
    filter     = attributes[:filter] || {}
    result =
      trailer
        .events
        .merge(date_range_scope(filter))
        .merge(kind_scope(filter))
        .includes(:trailer)
        .includes(:logistician)
        .includes(:linked_event)
        .includes(:interactions)
        .includes(:route_log)

    Success(result)
  end

  private

  def date_range_scope(filter)
    ::TrailerEvent.where(triggered_at: date_range(filter)).order(triggered_at: :desc)
  end

  def kind_scope(filter)
    return ::TrailerEvent.none if filter[:kinds].blank?

    ::TrailerEvent.where(kind: filter[:kinds])
  end

  def date_range(filter)
    from = filter[:date_from] || 1.day.ago
    to   = filter[:date_to]   || Time.current

    from..to
  end

  def validate(params)
    validated = Schema.call(params)
    return Failure(errors: validated.errors) if validated.failure?

    Success(validated.output)
  end

  def verify_trailer_permission(permission)
    return Failure(what: :no_permission) unless permission.event_log_access?

    Success(permission.trailer)
  end

  def find_permission(attributes)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(
      attributes[:auth],
      attributes[:trailer_id]
    )
  end
end
