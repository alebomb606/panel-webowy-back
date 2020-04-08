class TrailerSerializer < ApplicationSerializer
  attributes :hqtimezone, :device_serial_number, :registration_number, :device_installed_at, :make,
    :model, :description, :spedition_company, :transport_company, :status, :engine_running,
    :network_available, :updated_at, :data_usage, :camera_settings, :subscribed_at, :recording_list

  attribute :subscribed_at do |obj|
    obj.subscribed_at&.iso8601
  end

  attribute :camera_settings do |obj, settings = []|
    obj.cameras.each do |camera|
      settings << { camera_type: camera.camera_type, installed_at: camera.installed_at&.iso8601 }
    end
    settings
  end

  attribute :device_installed_at do |obj|
    obj.device_installed_at.iso8601
  end

  attribute :updated_at do |obj, params|
    query = ::Api::V1::Trailers::CurrentPositionQuery.new
    query.call(auth: params[:auth], trailer: obj) do |m|
      m.success do |position|
        query2 = ::Api::V1::Trailers::LastSensorQuery.new
        query2.call(auth: params[:auth], trailer: obj) do |m1|
          m1.success do |sensor|
            [sensor.read_at, position.sent_at].max
          end
          m1.failure do
            position.sent_at
          end
        end
      end
      m.failure do
        obj.updated_at.iso8601
      end
    end
  end

  attribute :current_position do |obj, params|
    query = ::Api::V1::Trailers::CurrentPositionQuery.new
    query.call(auth: params[:auth], trailer: obj) do |m|
      m.success do |position|
        {
          latitude: position.latitude,
          longitude: position.longitude,
          location_name: position.location_name,
          speed: position.speed,
          date: position.sent_at
        }
      end

      m.failure do
        nil
      end
    end
  end

  attribute :hqtimezone, &:hqtimezone

  has_one :access_permission,
    serializer: ::TrailerAccessPermissionSerializer,
    record_type: 'trailer_access_permission' do |obj, params|
    obj.access_permissions.find_by(logistician_id: params[:auth].logistician.id) if params[:auth]
  end
end
