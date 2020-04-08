class MasterAdmins::CompaniesController < MasterAdmins::BaseController
  def new
    render :new, locals: { company: ::Company.new }
  end

  def create
    ::MasterAdmin::Company::Register.new.call(company_params) do |r|
      r.success { |_| return redirect_to admin_companies_path, notice: t('.success') }
      r.failure { |monad| @errors = monad[:errors] }
    end

    render :new, locals: { company: ::Company.new(company_params) }
  end

  def edit
    company = ::Company.active.find(params[:id])
    render :edit, locals: { company: company }
  end

  def update
    ::MasterAdmin::Company::Update.new.call(update_company_params) do |r|
      r.success { |_| return redirect_to admin_companies_path, notice: t('.success') }
      r.failure(:company_not_found) do
        return redirect_to admin_companies_path, alert: t('master_admins.companies.not_found')
      end
      r.failure { |monad| @errors = monad[:errors] }
    end

    company = ::Company.active.find(params[:id])
    company.assign_attributes(company_params)
    render :edit, locals: { company: company }
  end

  def index
    companies = ::CompanyPresenter.wrap(::Company.active)
    render :index, locals: { companies: companies }
  end

  def destroy
    ::MasterAdmin::Company::Archive.new.call(params[:id]) do |r|
      r.success do |_|
        redirect_to admin_companies_path, notice: t('.success')
      end
      r.failure(:company_not_found) do |_|
        redirect_to admin_companies_path, alert: t('master_admins.companies.not_found')
      end
    end
  end

  def logisticians
    company = ::Company.find(params[:id])
    logisticians = ::LogisticianPresenter.wrap(company.logisticians.includes(:auth, :person).active)
    render :logisticians, locals: { company: ::CompanyPresenter.new(company), logisticians: logisticians }
  end

  private

  def company_params
    params.require(:company).permit(:name, :email, :nip, :city, :street, :postal_code, :email)
  end

  def update_company_params
    company_params.merge(id: params[:id])
  end
end
