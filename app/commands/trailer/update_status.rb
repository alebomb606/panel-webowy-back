class Trailer::UpdateStatus
  def initialize(trailer, status)
    @trailer = trailer
    @status  = status.to_s
  end

  def call
    @trailer.update(status: @status)
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
