class MasterAdmin::Trailer::AccessPermission::Grant < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:trailer_id).filled(:int?)
    required(:logistician_id).filled(:int?)

    optional(:alarm_control).filled(:bool?)
    optional(:alarm_resolve_control).filled(:bool?)
    optional(:system_arm_control).filled(:bool?)
    optional(:load_in_mode_control).filled(:bool?)

    optional(:photo_download).filled(:bool?)
    optional(:video_download).filled(:bool?)
    optional(:monitoring_access).filled(:bool?)

    optional(:current_position).filled(:bool?)
    optional(:route_access).filled(:bool?)

    optional(:sensor_access).filled(:bool?)
    optional(:event_log_access).filled(:bool?)
  end

  def call(params)
    attributes = yield validate(params.to_h)
    trailer = yield find_trailer(attributes[:trailer_id])
    yield find_logistician(trailer, attributes[:logistician_id])
    permission = grant_permissions(trailer, attributes)
    Success(permission)
  end

  private

  def find_logistician(trailer, id)
    Try(ActiveRecord::RecordNotFound) { trailer.company.logisticians.active.find(id) }
      .or { Failure(what: :logistician_not_found) }
  end

  def find_trailer(id)
    Try(ActiveRecord::RecordNotFound) { ::Trailer.active.find(id) }
      .or { Failure(what: :trailer_not_found) }
  end

  def validate(params)
    validation = Schema.call(params)

    if validation.failure?
      Failure(
        errors: validation.errors,
        permission: ::TrailerAccessPermission.new(validation.output)
      )
    else
      Success(validation.output)
    end
  end

  def grant_permissions(trailer, attributes)
    permission = trailer
      .access_permissions
      .find_by(logistician_id: attributes[:logistician_id])

    if permission
      permission.update(attributes)
      permission
    else
      trailer.access_permissions.create(attributes)
    end
  end
end
