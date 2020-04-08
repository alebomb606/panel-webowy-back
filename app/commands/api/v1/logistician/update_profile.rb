class Api::V1::Logistician::UpdateProfile < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      option :auth

      def unique?(value)
        ::Auth.where.not(id: auth.id).where(email: value).empty?
      end

      # rubocop:disable Rails/Delegate

      def valid_password?(value)
        auth.valid_password?(value)
      end

      # rubocop:enable Rails/Delegate

      config.type_specs = true
    end

    required(:auth, Types::Instance(::Auth)).filled
    required(:first_name, :string).filled(:str?)
    required(:last_name, :string).filled(:str?)
    required(:email, :string).filled(:email?, :unique?)
    required(:phone_number, Types::PhoneNumber).filled(:str?, :phone_number?)
    required(:password, :string).filled(:str?, :valid_password?)
    optional(:extra_phone_number, Types::PhoneNumber).maybe(:str?, :phone_number?)
    optional(:preferred_locale, :string).filled(:str?, included_in?: ::Logistician::LOCALES.keys.map(&:to_s))
    optional(:avatar, :string).maybe(:str?)
  end

  def call(params)
    attributes = yield validate(params)
    Success(update_logistician(attributes))
  end

  private

  def validate(params)
    validation = Schema.with(auth: params[:auth]).call(params.to_h)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def update_logistician(attributes)
    logistician = attributes[:auth].logistician
    logistician.auth.update(email: attributes[:email])
    logistician.person.update(attributes.except(:auth, :password, :preferred_locale))
    logistician.update(preferred_locale: attributes[:preferred_locale] || :pl)
    logistician
  end
end
