class Trailer::ReadStatus
  def initialize(trailer)
    @trailer = trailer
  end

  def call
    broadcast_trailer_data
    @trailer
  end

  private

  def broadcast_trailer_data
    @trailer.logisticians.each do |logistician|
      ::Auth::EntityBroadcaster.new(
        entities: @trailer.reload,
        auth: logistician.auth,
        serializer: ::TrailerSerializer
      ).call
    end
  end
end
