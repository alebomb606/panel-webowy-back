class Api::Safeway::RouteLog::LogFromWebsocket < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:latitude).filled(:decimal?, :latitude?)
    required(:longitude).filled(:decimal?, :longitude?)
    optional(:speed).filled(:decimal?, :speed?)
    optional(:timestamp).filled(:float?)
    optional(:sent_at).maybe(:time?)
  end

  def call(trailer, params)
    pos = {}
    if params.key?('1')
      params.each_key do |key|
        attributes = yield validate(params[key])
        position   = log_position(trailer, attributes)
        pos[:key] = position
      end
      Success(pos)
    else
      attributes = yield validate(params)
      position   = log_position(trailer, attributes)
      Success(position)
    end
  end

  private

  def validate(params)
    validation = Schema.call(params)
    return Failure(errors: validation.errors) if validation.failure?

    Success(parsed_attributes(validation.output))
  end

  def log_position(trailer, attributes)
    return if (attributes[:latitude] * attributes[:longitude]).zero?

    trailer.route_logs.create(
      reverse_geocoded_position(attributes)
    )
  end

  def reverse_geocoded_position(attributes)
    attributes.merge(
      ::ReverseGeocoder.call(
        latitude: attributes[:latitude],
        longitude: attributes[:longitude],
        language: :en
      )
    )
  end

  def parsed_attributes(attributes)
    # attributes[:speed] = attributes[:speed] unless attributes[:speed].nil?
    # attributes[:timestamp] = attributes[:timestamp] unless attributes[:timestamp].nil?
    attributes.merge(speed: attributes[:speed]) unless attributes[:speed].nil?
    attributes.merge!(
      sent_at: attributes[:sent_at] || !attributes[:timestamp].nil? ? Time.at(attributes[:timestamp]).utc : Time.current
    )
  end
end
