class MasterAdmins::CustomRoutesController < MasterAdmins::BaseController
  def new
    render :new, locals: { trailer_options: ::Trailer.active.pluck(:registration_number, :id) }
  end

  def create
    import = ::MasterAdmin::RouteLog::ImportFromGpx.new
    import.call(import_params) do |m|
      m.success do
        redirect_to new_admin_custom_route_path, notice: t('.success')
      end

      m.failure(:trailer_not_found) do
        redirect_to new_admin_custom_route_path, alert: t('master_admins.trailers.not_found')
      end

      m.failure do |res|
        @errors = res[:errors]
        new
      end
    end
  end

  private

  def import_params
    params.permit(:trailer_id, :file)
  end
end
