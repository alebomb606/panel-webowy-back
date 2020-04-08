class Api::Safeway::TrailerRecordingList::LogFromWebsocket < AppCommand
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)

  Schema = Dry::Validation.Schema do
    each do
      schema do
        required(:camera).filled(:str?)
        required(:entries).filled
      end
    end
  end

  def call(trailer, params)
    values = yield validate(params)
    update_trailer_recording_list(trailer, values)
    Success(trailer)
  end

  private

  def update_trailer_recording_list(trailer, params)
    trailer.update(recording_list: params)
  end

  def validate(params)
    attributes = JSON.parse(JSON[params], symbolize_names: true)
    validation = Schema.call(attributes)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(params)
    end
  end
end
