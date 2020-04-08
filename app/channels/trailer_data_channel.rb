class TrailerDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from "trailer_#{params[:uuid]}"
  end

  def perform_action(data)
    BANANA_LOGGER.info("Handling incoming data: #{data} from trailer {id: #{current_trailer.id}}")
    ::TrailerConnection::HandleData.new(current_trailer, data).call
  end
end
