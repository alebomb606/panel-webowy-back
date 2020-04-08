class TrailerEvent::LogLatestPosition
  POSITION_ATTRIBUTES = %w[latitude longitude location_name locale sent_at speed].freeze

  def self.call(event)
    return if event.blank?

    position = ::Trailers::CurrentPositionQuery.call(event.trailer)
    return if position.blank?

    event.create_route_log(
      position
        .attributes
        .slice(*POSITION_ATTRIBUTES)
    )
  end
end
