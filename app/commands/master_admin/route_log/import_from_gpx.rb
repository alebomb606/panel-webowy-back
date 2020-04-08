class MasterAdmin::RouteLog::ImportFromGpx < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:trailer_id).filled(:int?)
    required(:file).filled
  end

  def initialize
    @log_counter   = 0
    @event_per     = rand(10..50)
    @last_event_at = Time.current
  end

  def call(params)
    attributes = yield validate(params.to_h)
    trailer    = yield find_trailer(attributes[:trailer_id])
    file       = GpxRuby::File(attributes[:file].path)
    import_coordinates(file, trailer)
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

  def find_trailer(id)
    Try(ActiveRecord::RecordNotFound) { ::Trailer.active.find(id) }
      .or { Failure(what: :trailer_not_found) }
  end

  def event_loggable?
    @log_counter >= @event_per
  end

  def log_route(trailer, point)
    trailer.route_logs.create(
      latitude: point.lat,
      longitude: point.lon,
      sent_at: Time.current
    )
    @log_counter += 1
  end

  def log_event(trailer, point)
    trailer.events.create(
      kind: ::TrailerEvent.kinds.keys.sample,
      triggered_at: @last_event_at,
      sensor_name: 'co2',
      uuid: SecureRandom.uuid,
      latitude: point.lat,
      longitude: point.lon
    )
  end

  def reset_counters
    @last_event_at += rand(0..2000).seconds
    @log_counter   = 0
    @event_per     = rand(10..50)
  end

  def import_coordinates(file, trailer)
    file.tracks.each do |track|
      track.points.each do |point|
        log_route(trailer, point)
        next unless event_loggable?

        log_event(trailer, point)
        reset_counters
      end
    end
  end
end
