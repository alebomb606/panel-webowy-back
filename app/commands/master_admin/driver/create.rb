class MasterAdmin::Driver::Create < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      def unique?(attr_name, value)
        ::Person.where(attr_name => value).empty?
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
    attributes = yield validate(params.to_h)
    yield find_company(attributes[:person_attributes][:company_id])
    Success(::Driver.create(attributes))
  end

  private

  def find_company(id)
    Try { ::Company.active.find(id) }.or { Failure(what: :company_not_found) }
  end

  def validate(params)
    validation = Schema.call(params)

    if validation.failure?
      Failure(errors: validation.errors, attributes: validation.output)
    else
      Success(validation.output)
    end
  end
end
