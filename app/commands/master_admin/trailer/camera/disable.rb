class MasterAdmin::Trailer::Camera::Disable < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  def call(camera_id)
    camera = yield find_camera(camera_id)
    Success(disable_camera(camera))
  end

  private

  def find_camera(camera_id)
    Try(ActiveRecord::RecordNotFound) { ::TrailerCamera.find(camera_id) }.or { Failure(what: :not_found) }
  end

  def disable_camera(camera)
    camera.update(installed_at: nil)
    camera
  end
end
