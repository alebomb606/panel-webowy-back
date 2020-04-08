class MasterAdmins::DriversController < MasterAdmins::BaseController
  def index
    drivers = ::Driver.includes(person: :company).active
    render :index, locals: { drivers: drivers }
  end

  def new
    render :new, locals: form_locals
  end

  def create
    create = ::MasterAdmin::Driver::Create.new
    create.call(driver_params) do |m|
      m.success do
        redirect_to admin_drivers_path, notice: t('.success')
      end

      m.failure(:company_not_found) do
        redirect_to admin_drivers_path, alert: t('master_admins.companies.not_found')
      end

      m.failure do |result|
        @errors = result[:errors]
        render :new, locals: form_locals(result[:attributes])
      end
    end
  end

  def edit
    driver = ::Driver.find(params[:id])
    render :edit, locals: form_locals(driver)
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_drivers_path, alert: t('master_admins.drivers.not_found')
  end

  def update
    update = ::MasterAdmin::Driver::Update.new
    update.call(driver_params) do |m|
      m.success do
        redirect_to admin_drivers_path, notice: t('.success')
      end

      m.failure(:company_not_found) do
        redirect_to admin_drivers_path, alert: t('master_admins.companies.not_found')
      end

      m.failure(:driver_not_found) do
        redirect_to admin_drivers_path, alert: t('master_admins.drivers.not_found')
      end

      m.failure do |result|
        @errors = result[:errors]
        render :edit, locals: form_locals(result[:driver])
      end
    end
  end

  def destroy
    ::Driver.destroy(params[:id])
    redirect_to admin_drivers_path, notice: t('.success')
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_drivers_path, alert: t('master_admins.drivers.not_found')
  end

  private

  def form_locals(driver_attributes = {})
    driver = driver_attributes.is_a?(::Driver) ? driver_attributes : ::Driver.new(driver_attributes)
    { driver: driver, companies: ::Company.active.pluck(:name, :id) }
  end

  def driver_params
    params.require(:driver).permit(
      person_attributes: %i[first_name last_name phone_number extra_phone_number company_id email avatar]
    ).merge(id: params[:id])
  end
end
