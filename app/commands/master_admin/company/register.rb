class MasterAdmin::Company::Register < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      def unique?(attr_name, value)
        ::Company.active.where(attr_name => value).empty?
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
    params = remove_extra_signs_from_nip(params)
    attributes = yield validate(params)
    Success(::Company.create(attributes))
  end

  private

  def remove_extra_signs_from_nip(params)
    return params unless params[:nip]

    params[:nip] = params[:nip].delete('-')
    params
  end

  def validate(params)
    validation = Schema.call(params)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end
end
