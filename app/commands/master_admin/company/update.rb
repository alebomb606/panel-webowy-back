class MasterAdmin::Company::Update < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      option :record

      def unique?(attr_name, value)
        ::Company.active.where.not(id: record.id)
          .where(attr_name => value).empty?
      end
    end

    required(:name).filled(:str?, unique?: :name)
    required(:email).filled(:email?, unique?: :email)
    required(:nip).filled(format?: /\A\d{10}\z/, unique?: :nip)
    required(:city).filled(:str?)
    required(:street).filled(:str?)
    required(:postal_code).filled(:str?)
  end

  def call(params)
    company = yield find_company(params[:id])
    params = remove_extra_signs_from_nip(params)
    attributes = yield validate(company, params)
    company = update_company(company, attributes)
    Success(company)
  end

  private

  def remove_extra_signs_from_nip(params)
    return params unless params[:nip]

    params[:nip] = params[:nip].delete('-')
    params
  end

  def find_company(id)
    Try(ActiveRecord::RecordNotFound) { ::Company.active.find(id) }.or { Failure(what: :company_not_found) }
  end

  def validate(company, params)
    validation = Schema
      .with(record: company)
      .call(params)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def update_company(company, attributes)
    company.update(attributes)
    company
  end
end
