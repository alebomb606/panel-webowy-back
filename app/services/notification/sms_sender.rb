class Notification::SmsSender
  def initialize
    @client = Twilio::REST::Client.new(
      Rails.application.secrets.twilio_account_sid,
      Rails.application.secrets.twilio_auth_token
    )
  end

  def call(to:, body:)
    @client.api.account.messages.create(
      from: Rails.application.secrets.twilio_from_number.to_s,
      to: to,
      body: body
    )
  end
end
