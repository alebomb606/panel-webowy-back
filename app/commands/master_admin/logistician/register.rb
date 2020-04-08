class MasterAdmin::Logistician::Register < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      def unique?(attr_name, value)
        ::Auth.where(attr_name => value).empty?
      end
    end

    required(:person_attributes).schema do
      required(:company_id).filled(:int?)
      required(:first_name).filled(:str?)
      required(:last_name).filled(:str?)
      required(:email).filled(:email?, unique?: :email)
      required(:phone_number).filled(:phone_number?)
      optional(:extra_phone_number).maybe(:phone_number?)
      optional(:avatar).maybe
    end

    optional(:preferred_locale, :string).filled(:str?, included_in?: ::Logistician::LOCALES.keys.map(&:to_s))
  end

  def call(params)
    attributes  = yield validate(params.to_h)
    company     = yield find_company(attributes[:person_attributes][:company_id])
    logistician = create_logistician(company, attributes)
    Success(logistician)
  end

  private

  def find_company(id)
    Try { ::Company.active.find(id) }.or { Failure(what: :not_found) }
  end

  def validate(params)
    validation = Schema.call(params)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def create_logistician(company, attributes)
    logistician = company.logisticians.create(preferred_locale: attributes[:preferred_locale] || :pl)
    logistician.create_person(attributes[:person_attributes])
    logistician.create_auth(email: logistician.person.email)
    logistician
  end
end
