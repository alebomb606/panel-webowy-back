class MasterAdmins::TrailersController < MasterAdmins::BaseController
  def new
    render :new, locals: form_locals(::Trailer.new)
  end

  def create
    ::MasterAdmin::Trailer::InstallDevice.new.call(trailer_params) do |r|
      r.success { |_| return redirect_to admin_trailers_path, notice: t('.success') }
      r.failure(:not_found) do
        return redirect_to admin_trailers_path, alert: t('master_admins.companies.not_found')
      end
      r.failure { |monad| @errors = monad[:errors] }
    end
    render :new, locals: form_locals(::Trailer.new(trailer_params))
  end

  def edit
    render :edit, locals: form_locals(::Trailer.active.find(params[:id]))
  end

  def update
    ::MasterAdmin::Trailer::UpdateDevice.new.call(update_trailer_params) do |r|
      r.success { |_| return redirect_to admin_trailers_path, notice: t('.success') }
      r.failure(:trailer_not_found) do
        return redirect_to admin_trailers_path, alert: t('master_admins.trailers.not_found')
      end
      r.failure(:company_not_found) do
        return redirect_to admin_trailers_path, alert: t('master_admins.companies.not_found')
      end
      r.failure { |monad| @errors = monad[:errors] }
    end

    trailer = ::Trailer.active.find(params[:id])
    trailer.assign_attributes(trailer_params)
    render :edit, locals: form_locals(trailer)
  end

  def index
    trailers = ::TrailerPresenter.wrap(::Trailer.includes(:company).active)
    render :index, locals: { trailers: trailers }
  end

  def destroy
    ::MasterAdmin::Trailer::Archive.new.call(params[:id]) do |r|
      r.success do |_|
        redirect_to admin_trailers_path, notice: t('.success')
      end
      r.failure(:trailer_not_found) do |_|
        redirect_to admin_trailers_path, alert: t('master_admins.trailers.not_found')
      end
    end
  end

  private

  def form_locals(trailer)
    trailer.build_plan(selected_features: Plan.features_for('fundamental')) unless trailer.plan
    {
      trailer: trailer,
      companies: ::Company.active.pluck(:name, :id),
      makes: ::Trailer.makes_for_select_box,
      plan_kinds: ::Plan.kinds.keys.map { |kind| [kind.humanize, kind] }
    }
  end

  def update_trailer_params
    trailer_params.merge(id: params[:id])
  end

  def trailer_params
    params.require(:trailer).permit(
      :device_serial_number,
      :registration_number,
      :company_id,
      :make,
      :model,
      :description,
      :device_installed_at,
      :banana_pi_token,
      :spedition_company,
      :transport_company,
      :engine_running,
      :hqtimezone,
      :phone_number,
      plan_attributes: {}
    )
  end
end
