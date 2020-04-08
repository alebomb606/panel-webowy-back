class MasterAdmin::Logistician::Update < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      option :record

      def unique?(attr_name, value)
        ::Auth.where.not(logistician_id: record.id).where(attr_name => value).empty?
      end

      config.type_specs = true
    end

    required(:id, :integer).filled(:int?)

    required(:person_attributes).schema do
      required(:company_id, :integer).filled(:int?)
      required(:first_name, :string).filled(:str?)
      required(:last_name, :string).filled(:str?)
      required(:email, :string).filled(:email?, unique?: :email)
      required(:phone_number, Types::PhoneNumber).filled(:str?, :phone_number?)
      optional(:extra_phone_number, Types::PhoneNumber).maybe(:str?, :phone_number?)
      optional(:avatar, Types.Instance(ActionDispatch::Http::UploadedFile)).maybe
    end

    optional(:preferred_locale, :string).filled(:str?, included_in?: ::Logistician::LOCALES.keys.map(&:to_s))
  end

  def call(params)
    logistician = yield find_logistician(params[:id])
    attributes  = yield validate(logistician, params)
    yield find_company(attributes[:person_attributes][:company_id])
    logistician = update_logistician(logistician, attributes)
    Success(logistician)
  end

  private

  def find_company(id)
    Try { ::Company.active.find(id) }.or { Failure(what: :company_not_found) }
  end

  def find_logistician(id)
    Try { ::Logistician.active.find(id) }.or { Failure(what: :logistician_not_found) }
  end

  def validate(logistician, params)
    validation = Schema
      .with(record: logistician)
      .call(params.to_h)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def update_logistician(logistician, attributes)
    person_attributes = attributes[:person_attributes]
    logistician.update(preferred_locale: attributes[:preferred_locale] || :pl)
    logistician.auth.update(email: person_attributes[:email])
    logistician.person.update(person_attributes)
    logistician
  end
end
