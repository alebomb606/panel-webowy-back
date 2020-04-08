class Api::V1::TrailerEvent::ResolveAlarm < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:auth).filled
    required(:id).filled(:int?)
  end

  KindSchema = Dry::Validation.Params(::AppSchema) do
    required(:kind).filled { included_in?(%w[alarm quiet_alarm emergency_call]) }
  end

  def call(params)
    attributes = yield validate(Schema, params)
    event      = yield find_event(attributes[:id])
    yield validate(KindSchema, kind: event.kind)
    permission = yield find_permission(auth: attributes[:auth], id: event.trailer_id)
    yield verify_trailer_permission(permission)
    interaction = resolve_alarm(event, attributes[:auth])
    broadcast_event_to_logisticians(interaction.linked_event)
    Success(interaction)
  end

  private

  def find_permission(attributes)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(
      attributes[:auth],
      attributes[:id]
    )
  end

  def find_event(id)
    Try(ActiveRecord::RecordNotFound) { ::TrailerEvent.find(id) }
      .or { Failure(what: :event_not_found) }
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
    return Failure(what: :no_permission) unless permission.alarm_resolve_control?

    Success(permission.trailer)
  end

  def resolve_alarm(event, auth)
    event.trailer.events.create(
      kind: :alarm_resolved,
      triggered_at: Time.current,
      logistician: auth.logistician,
      uuid: SecureRandom.uuid,
      linked_event: event
    )
  end

  def broadcast_event_to_logisticians(event)
    event.trailer.logisticians.each do |logistician|
      ::Auth::EntityBroadcaster.new(
        entities: event,
        auth: logistician.auth,
        serializer: ::TrailerEventSerializer,
        options: { include: %i[interactions interactions.logistician] }
      ).call
    end
  end
end
