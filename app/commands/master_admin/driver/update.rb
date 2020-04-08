class MasterAdmin::Driver::Update < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      option :person

      def unique?(attr_name, value)
        ::Person.where.not(id: person.id).where(attr_name => value).empty?
      end
    end

    required(:person_attributes).schema do
      required(:company_id).filled(:int?)
      required(:first_name).filled(:str?)
      required(:last_name).filled(:str?)
      required(:phone_number).filled(:phone_number?)
      optional(:email).maybe(:email?, unique?: :email)
      optional(:extra_phone_number).maybe(:phone_number?)
      optional(:avatar).maybe
    end
  end

  def call(params)
    driver      = yield find_driver(params[:id])
    attributes  = yield validate(driver, params.to_h)
    yield find_company(attributes[:person_attributes][:company_id])
    Success(update_driver(driver, attributes))
  end

  private

  def find_company(id)
    Try { ::Company.active.find(id) }.or { Failure(what: :company_not_found) }
  end

  def find_driver(id)
    Try { ::Driver.active.find(id) }.or { Failure(what: :driver_not_found) }
  end

  def validate(driver, params)
    validation = Schema.with(person: driver.person).call(params)

    if validation.failure?
      Failure(errors: validation.errors, driver: driver)
    else
      Success(validation.output)
    end
  end

  def update_driver(driver, attributes)
    driver.person.update(attributes[:person_attributes])
    driver.update(attributes.except(:person_attributes))
    driver
  end
end
