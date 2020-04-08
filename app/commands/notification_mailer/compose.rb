class NotificationMailer::Compose < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:body).filled(:str?)
    required(:email_priority).filled(:str?, included_in?: ::EmailNotification::EMAIL_PRIORITIES.keys.map(&:to_s))
    required(:event_date).filled(:time?)
    required(:lang).filled(:str?)
    required(:receiver_email).filled(:str?)
    required(:subject).filled(:str?)
    required(:user_company).filled(:str?)
    required(:user_name).filled(:str?)
  end

  def call(params)
    attributes = yield validate(params.to_h)
    store_notification_in_history(attributes)
    send_email_notification
    Success(@notification)
  end

  private

  def validate(params)
    validation = Schema.call(params)
    if validation.failure?
      Failure(errors: validation.errors, attributes: validation.output)
    else
      Success(validation.output)
    end
  end

  def send_email_notification
    ::NotificationMailer.notification_mail(@notification).deliver_later
  end

  def store_notification_in_history(attributes)
    @notification = ::EmailNotification.create(attributes)
  end
end
