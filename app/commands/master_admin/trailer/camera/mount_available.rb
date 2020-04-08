class MasterAdmin::Trailer::Camera::MountAvailable
  def call(trailer)
    ::TrailerCamera.camera_types.keys.each do |camera_type|
      trailer.cameras.find_or_create_by(camera_type: camera_type)
    end
  end
end
