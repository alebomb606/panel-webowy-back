class MasterAdmin::Register < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      def unique?(attr_name, value)
        ::Auth.where(attr_name => value).empty?
      end
    end

    required(:first_name).filled(:str?)
    required(:last_name).filled(:str?)
    required(:email).filled(:email?, unique?: :email)
    optional(:phone_number).filled(:str?)
  end

  def call(params)
    attributes   = yield validate(params)
    master_admin = create_master_admin(attributes)
    Success(master_admin)
  end

  private

  def validate(params)
    validation = Schema.call(params)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def create_master_admin(attributes)
    master_admin = MasterAdmin.create(attributes.except(:email))
    master_admin.create_auth(email: attributes[:email])
    master_admin
  end
end
