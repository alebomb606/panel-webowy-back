class MasterAdmin::Trailer::Camera::Enable < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  def call(camera_id)
    camera = yield find_camera(camera_id)
    Success(enable_camera(camera))
  end

  private

  def find_camera(camera_id)
    Try(ActiveRecord::RecordNotFound) { ::TrailerCamera.find(camera_id) }.or { Failure(what: :not_found) }
  end

  def enable_camera(camera)
    camera.update(installed_at: Time.current)
    camera
  end
end
