class Api::V1::Trailers::Media::FilterQuery < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  module Types
    include Dry::Types.module

    ArrayFromRequest = Types::String.constructor do |str|
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
      optional(:cameras, Types::ArrayFromRequest).maybe(:array?) do
        each { included_in?(::DeviceMediaFile.cameras.keys) }
      end
      optional(:kinds, Types::ArrayFromRequest).maybe(:array?) do
        each { included_in?(::DeviceMediaFile.kinds.keys) }
      end
      optional(:statuses, Types::ArrayFromRequest).maybe(:array?) do
        each { included_in?(::DeviceMediaFile.statuses.keys) }
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
        .media_files
        .includes(:trailer_event)
        .includes(:trailer)
        .includes(:logistician)
        .includes(:route_log)
        .merge(date_range_scope(filter))
        .merge(cameras_filter(filter))
        .merge(kinds_filter(filter))
        .merge(statuses_filter(filter))

    Success(result)
  end

  private

  def date_range_scope(filter)
    ::DeviceMediaFile.where(requested_time: date_range(filter)).order(requested_time: :desc)
  end

  def cameras_filter(filter)
    return ::DeviceMediaFile.all if filter[:cameras].blank?

    ::DeviceMediaFile.where(camera: filter[:cameras])
  end

  def kinds_filter(filter)
    return ::DeviceMediaFile.all if filter[:kinds].blank?

    ::DeviceMediaFile.where(kind: filter[:kinds])
  end

  def statuses_filter(filter)
    return ::DeviceMediaFile.all if filter[:statuses].blank?

    ::DeviceMediaFile.where(status: filter[:statuses])
  end

  def date_range(filter)
    from = filter[:date_from] || 7.days.ago
    to   = filter[:date_to]   || Time.current

    from..to
  end

  def validate(params)
    validated = Schema.call(params)
    return Failure(errors: validated.errors) if validated.failure?

    Success(validated.output)
  end

  def verify_trailer_permission(permission)
    return Failure(what: :no_permission) unless permission.monitoring_access?

    Success(permission.trailer)
  end

  def find_permission(attributes)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(
      attributes[:auth],
      attributes[:trailer_id]
    )
  end
end
