class Api::V1::Logistician::UpdatePassword < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      option :auth

      # rubocop:disable Rails/Delegate

      def valid_password?(value)
        auth.valid_password?(value)
      end

      # rubocop:enable Rails/Delegate
    end

    required(:auth).filled
    required(:current_password).filled(:str?, :valid_password?)
    required(:password).filled(:str?, size?: Devise.password_length).confirmation
  end

  def call(params)
    attributes = yield validate(params)
    Success(update_password(attributes))
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

  def update_password(attributes)
    attributes[:auth].update(password: attributes[:password])
    attributes[:auth].logistician
  end
end
