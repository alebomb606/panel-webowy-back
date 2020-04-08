class Api::V1::Trailers::EventsController < Api::BaseController
  def index
    query = ::Api::V1::Trailers::Events::FilterQuery.new
    query.call(filter_params.merge(auth: current_auth)) do |m|
      m.success do |res|
        paginated = paginate(res)
        render json: ::TrailerEventSerializer.new(
          paginated,
          links: pagination_links(paginated),
          params: { auth: current_auth },
          include: %i[trailer route_log logistician linked_event interactions interactions.logistician]
        )
      end

      m.failure(:trailer_not_found) do
        render json: ::ErrorSerializer.not_found('Trailer'), status: :not_found
      end

      m.failure(:no_permission) do
        head :forbidden
      end

      m.failure do |res|
        render json: ::ErrorSerializer.wrap(res[:errors]), status: :unprocessable_entity
      end
    end
  end

  def resolve_alarm
    resolve = ::Api::V1::TrailerEvent::ResolveAlarm.new
    resolve.call(resolve_alarm_params.merge(auth: current_auth)) do |m|
      m.success do |event|
        render json: ::TrailerEventSerializer.new(
          event.linked_event,
          params: { auth: current_auth },
          include: %i[interactions interactions.logistician]
        )
      end

      m.failure(:event_not_found) do
        render json: ::ErrorSerializer.not_found('Event'), status: :not_found
      end

      m.failure(:no_permission) do
        head :forbidden
      end

      m.failure do |result|
        render json: ::ErrorSerializer.wrap(result[:errors]), status: :unprocessable_entity
      end
    end
  end

  private

  def filter_params
    params.permit(:trailer_id, filter: %i[date_from date_to kinds])
  end

  def resolve_alarm_params
    params.permit(:id).merge(auth: current_auth)
  end
end
