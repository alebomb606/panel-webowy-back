class Api::Safeway::TrailerEvent::LogFromWebsocket < AppCommand
  include Dry::Monads::Do.for(:call, :log_events)
  include Dry::Matcher.for(:call, with: Matcher)

  LocationSchema = Dry::Validation.Params(::AppSchema) do
    optional(:latitude).maybe(:decimal?, :latitude?) { decimal? | float? }
    optional(:longitude).maybe(:decimal?, :longitude?) { decimal? | float? }
  end

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:input).filled do
      each do
        schema do
          required(:type).filled(included_in?: ::TrailerEvent.kinds.keys)
          required(:date).filled { float? | int? }
          required(:uuid).filled(:str?)
          optional(:sensor).maybe(:str?)
          optional(:gps).maybe do
            schema(LocationSchema)
          end
        end
      end
    end
  end

  def call(trailer, params)
    events_attributes = yield validate(params)
    events = yield log_events(trailer, events_attributes)
    return Success(trailer) if events.empty?

    request_media(events)
    update_trailer_status(trailer, events.last.kind)
    Success(trailer)
  end

  private

  def resolve_params(params)
    return [params] if params.is_a?(Hash)

    params
  end

  def validate(params)
    params     = resolve_params(params)
    validation = Schema.call(input: params)
    return Failure(errors: validation.errors[:input]) if validation.failure?

    Success(validation.output[:input])
  end

  def log_events(trailer, events_attributes)
    logged_events = []

    events_attributes.each do |attributes|
      event = yield ::Api::Safeway::TrailerEvent::Log.new.call(prepare_attributes(trailer, attributes))
      ::Api::Safeway::AcknowledgeEvent.call(trailer, attributes[:uuid])
      next unless event

      log_position(event, attributes[:gps])
      logged_events << event
    end

    Success(logged_events)
  end

  def log_position(event, coordinates)
    return if coordinates.nil?

    params = {
      trailer_event_id: event.id,
      latitude: coordinates[:latitude],
      longitude: coordinates[:longitude]
    }
    ::RouteLog::LogPositionForAssociation.call(params)
  end

  def prepare_attributes(trailer, attributes)
    {
      trailer: trailer,
      kind: attributes[:type],
      triggered_at: Time.zone.at(attributes[:date]),
      sensor_name: attributes[:sensor],
      uuid: attributes[:uuid]
    }
  end

  def request_media(events)
    events.each do |event|
      next unless event.alarm?

      media_file = save_event_media(event)
      ::Api::Safeway::RequestMedia.call(event.trailer, media_file, true)
    end
  end

  def save_event_media(event)
    event.trailer.media_files.create(
      kind: :photo,
      uuid: SecureRandom.uuid,
      status: :request,
      camera: :interior,
      trailer_event: event,
      requested_time: event.triggered_at
    )
  end

  def update_trailer_status(trailer, status)
    return if status == 'warning'

    ::Trailer::UpdateStatus.new(trailer, status).call
  end
end
