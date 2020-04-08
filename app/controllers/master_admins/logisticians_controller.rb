class MasterAdmins::LogisticiansController < MasterAdmins::BaseController
  def new
    logistician = ::Logistician.new
    companies   = ::Company.active.pluck(:name, :id)
    render :new, locals: { logistician: logistician, companies: companies }
  end

  def create
    register = ::MasterAdmin::Logistician::Register.new
    register.call(logistician_params) do |r|
      r.success { return redirect_to new_admin_logistician_path, notice: t('.success') }
      r.failure(:not_found) do
        return redirect_to admin_logisticians_path, alert: t('master_admins.logisticians.not_found')
      end
      r.failure { |monad| @errors = monad[:errors] }
    end

    logistician = ::Logistician.new(logistician_params)
    companies = ::Company.active.pluck(:name, :id)
    render :new, locals: { logistician: logistician, companies: companies }
  end

  def edit
    logistician = ::Logistician.active.find(params[:id])
    companies = ::Company.active.pluck(:name, :id)
    render :edit, locals: { logistician: logistician, companies: companies }
  end

  def update
    update = ::MasterAdmin::Logistician::Update.new
    update.call(logistician_params) do |r|
      r.success { return redirect_to admin_logisticians_path, notice: t('.success') }
      r.failure(:logistician_not_found) do
        return redirect_to admin_logisticians_path, alert: t('master_admins.logisticians.not_found')
      end
      r.failure(:company_not_found) do
        return redirect_to admin_logisticians_path, alert: t('master_admins.companies.not_found')
      end
      r.failure { |monad| @errors = monad[:errors] }
    end

    logistician = ::Logistician.active.find(params[:id])
    logistician.assign_attributes(logistician_params)
    # fails when provided country is not present in enum
    companies = ::Company.active.pluck(:name, :id)
    render :edit, locals: { logistician: logistician, companies: companies }
  end

  def index
    logisticians = ::LogisticianPresenter.wrap(::Logistician.includes(:auth, person: :company).active)
    render :index, locals: { logisticians: logisticians }
  end

  def show
    logistician = ::Logistician.active.find(params[:id])
    assigned_trailers = logistician.trailers.active.includes(:company)
    unassigned_trailers = ::Trailer
      .includes(:company)
      .active
      .where(company_id: logistician.person.company.id)
      .where.not(id: assigned_trailers.pluck(:id))
    assigned_trailers = ::TrailerPresenter.wrap(assigned_trailers)
    unassigned_trailers = ::TrailerPresenter.wrap(unassigned_trailers)
    logistician = ::LogisticianPresenter.new(logistician)

    render :show, locals: {
      assigned_trailers: assigned_trailers,
      unassigned_trailers: unassigned_trailers,
      logistician: logistician
    }
  end

  def unassign_trailer
    ::MasterAdmin::Logistician::UnassignTrailer.new.call(trailer_management_params) do |r|
      r.success do
        return redirect_to admin_logistician_path(params[:id]), notice: t('.success')
      end
      r.failure(:logistician_not_found) do
        return redirect_to admin_logisticians_path, alert: t('master_admins.logisticians.not_found')
      end
      r.failure(:trailer_not_found) do
        return redirect_to admin_logisticians_path, alert: t('master_admins.trailers.not_found')
      end
    end

    logistician = ::Logistician.active.find(params[:id])
    render :show, locals: { logistician: logistician }
  end

  def destroy
    ::MasterAdmin::Logistician::Archive.new.call(params[:id]) do |r|
      r.success do
        redirect_to admin_logisticians_path, notice: t('.success')
      end
      r.failure(:logistician_not_found) do
        redirect_to admin_logisticians_path, alert: t('master_admins.logisticians.not_found')
      end
    end
  end

  private

  def trailer_management_params
    params.permit(:id, :trailer_id)
  end

  def logistician_params
    params.require(:logistician).permit(
      :preferred_locale,
      person_attributes: %i[first_name last_name phone_number extra_phone_number company_id email avatar]
    ).merge(id: params[:id])
  end
end
