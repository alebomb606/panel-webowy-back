class TrailerEvent::LogInteraction
  def initialize(trailer, attributes = {})
    @trailer     = trailer.reload
    @attributes  = attributes
    @kind        = attributes[:kind]
    @logistician = attributes[:logistician]
    @reading     = attributes[:sensor_reading]
  end

  def call
    return unless reading_triggers_event?

    end_loading
    send_command_to_safeway_device
    create_event
    broadcast_event_data
    @event
  end

  private

  def end_loading
    return unless @trailer.end_loading_possible_with?(@kind)

    self.class.new(@trailer, kind: 'end_loading', logistician: @logistician).call
  end

  def send_command_to_safeway_device
    ::Api::Safeway::SendCommand.call(@trailer, @kind) if @logistician || @kind == 'end_loading'
  end

  def create_event
    @event = @trailer.events.create(
      kind: @kind,
      triggered_at: @attributes[:triggered_at] || Time.current,
      logistician: @logistician,
      sensor_reading: @reading,
      sensor_name: @attributes[:sensor_name],
      uuid: @attributes[:uuid] || SecureRandom.uuid,
      linked_event: fetch_event_interaction
    )
  end

  def fetch_event_interaction
    @trailer.events.where(kind: ::Trailer::INTERACTIONS[@kind]).order(triggered_at: :desc).first
  end

  def broadcast_event_data
    @trailer.logisticians.each do |logistician|
      ::Auth::EntityBroadcaster.new(
        entities: @event,
        auth: logistician.auth,
        serializer: ::TrailerEventSerializer
      ).call
    end
  end

  def reading_triggers_event?
    return true if @reading.blank?

    @reading.event_triggerable?
  end
end
