class NotificationMailer < ApplicationMailer
  default from: "#{Rails.application.secrets.mailer[:sender_name]} <#{Rails.application.secrets.mailer[:sender_email]}>"
  layout 'mailer'

  def notification_mail(notification)
    @notification = notification
    I18n.with_locale(@notification.lang) do
      mail(to: @notification.receiver_email,
           subject: @notification.subject,
           'X-Priority': @notification.email_priority_before_type_cast) do |format|
        format.text
        format.html
      end
    end
  end
end
