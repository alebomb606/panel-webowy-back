class MasterAdmins::TrailerCamerasController < MasterAdmins::BaseController
  def index
    trailer = ::Trailer.find(params[:trailer_id])
    render :index, locals: { cameras: trailer.cameras.order(:camera_type) }
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_trailers_path, alert: t('master_admins.trailer_cameras.not_found')
  end

  def enable
    cmd = ::MasterAdmin::Trailer::Camera::Enable.new
    cmd.call(params[:camera_id]) do |m|
      m.success do |r|
        redirect_to admin_trailer_cameras_path(r.trailer_id), notice: t('master_admins.trailer_cameras.enabled')
      end

      m.failure(:not_found) do
        redirect_to admin_trailers_path, alert: t('master_admins.trailer_cameras.not_found')
      end
    end
  end

  def disable
    cmd = ::MasterAdmin::Trailer::Camera::Disable.new
    cmd.call(params[:camera_id]) do |m|
      m.success do |r|
        redirect_to admin_trailer_cameras_path(r.trailer_id), notice: t('master_admins.trailer_cameras.disabled')
      end

      m.failure(:not_found) do
        redirect_to admin_trailers_path, alert: t('master_admins.trailer_cameras.not_found')
      end
    end
  end
end
