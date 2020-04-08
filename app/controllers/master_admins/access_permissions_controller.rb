class MasterAdmins::AccessPermissionsController < MasterAdmins::BaseController
  def index
    trailer = ::Trailer.find(params[:trailer_id])
    render :index, locals: {
      permissions: trailer.access_permissions.joins(:logistician).merge(::Logistician.active),
      trailer: ::TrailerPresenter.new(trailer)
    }
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_trailers_path, alert: t('master_admins.access_permissions.not_found')
  end

  def new
    trailer = ::Trailer.find(params[:trailer_id])
    render :new, locals: form_locals(trailer.access_permissions.new)
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_trailers_path, alert: t('master_admins.access_permissions.not_found')
  end

  def edit
    permission = ::TrailerAccessPermission.find(params[:id])
    render :edit, locals: form_locals(permission)
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_trailers_path, alert: t('master_admins.access_permissions.not_found')
  end

  def create
    grant = ::MasterAdmin::Trailer::AccessPermission::Grant.new
    grant.call(access_permission_params) do |m|
      m.success do
        redirect_to admin_logistician_path(access_permission_params[:logistician_id]), notice: t('.success')
      end

      m.failure(:logistician_not_found) do
        redirect_to admin_logisticians_path, alert: t('master_admins.logisticians.not_found')
      end

      m.failure(:trailer_not_found) do
        redirect_to admin_logistician_path(access_permission_params[:logistician_id]),
          alert: t('master_admins.trailers.not_found')
      end

      m.failure do |result|
        @errors = result[:errors]
        render :new, locals: form_locals(result[:permission])
      end
    end
  end

  def update
    update = ::MasterAdmin::Trailer::AccessPermission::Update.new
    update.call(access_permission_params) do |m|
      m.success do
        redirect_to admin_logistician_path(access_permission_params[:logistician_id]), notice: t('.success')
      end

      m.failure(:logistician_not_found) do
        redirect_to admin_logisticians_path, alert: t('master_admins.logisticians.not_found')
      end

      m.failure(:permission_not_found) do
        redirect_to admin_logistician_path(access_permission_params[:logistician_id]),
          alert: t('master_admins.access_permissions.not_found')
      end

      m.failure do |result|
        @errors = result[:errors]
        render :edit, locals: form_locals(result[:permission])
      end
    end
  end

  private

  def form_locals(permission)
    logistician = ::Logistician.active.find(
      params[:logistician_id].presence || access_permission_params[:logistician_id]
    )
    {
      permission: permission,
      trailer_presenter: TrailerPresenter.new(permission.trailer),
      logistician_presenter: LogisticianPresenter.new(logistician)
    }
  end

  def access_permission_params
    params
      .require(:trailer_access_permission)
      .permit(
        %i[
          logistician_id sensor_access event_log_access alarm_control
          system_arm_control load_in_mode_control photo_download
          video_download monitoring_access current_position route_access
          alarm_resolve_control
        ]
      )
      .merge(
        params.permit(%i[id trailer_id logistician_id])
      )
  end
end
