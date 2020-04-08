class MasterAdmin::Trailer::AccessPermission::Update < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:id).filled(:int?)
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
    permission  = yield find_permission(params[:id])
    attributes  = yield validate(permission, params.to_h)
    yield find_logistician(attributes[:logistician_id])

    update_permission(permission, attributes)
    Success(permission)
  end

  private

  def find_logistician(id)
    Try(ActiveRecord::RecordNotFound) { ::Logistician.active.find(id) }
      .or { Failure(what: :logistician_not_found) }
  end

  def find_permission(id)
    Try(ActiveRecord::RecordNotFound) { ::TrailerAccessPermission.find(id) }
      .or { Failure(what: :permission_not_found) }
  end

  def update_permission(permission, attributes)
    permission.update(attributes.except(:id, :logistician_id, :trailer_id))
  end

  def validate(permission, params)
    validation = Schema.call(params)

    if validation.failure?
      Failure(errors: validation.errors, permission: permission)
    else
      Success(validation.output)
    end
  end
end
