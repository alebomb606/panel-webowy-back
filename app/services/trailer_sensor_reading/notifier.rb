class TrailerSensorReading::Notifier
  def initialize(reading)
    @reading = reading
    @setting = reading.sensor.setting
    @trailer = reading.sensor.trailer
  end

  def call
    return unless @reading.notifiable?

    send_email_notifications
    send_sms_notifications
    @reading
  end

  private

  def send_email_notifications
    return unless @setting.send_email?

    @setting.email_addresses.each do |email|
      ::OldNotificationMailer.sensor_alert(@reading.id, email).deliver_later
      save_notification(:email, email)
    end
  end

  def send_sms_notifications
    return unless @setting.send_sms?

    @setting.phone_numbers.each do |phone_number|
      ::Notification::SmsSenderWorker.perform_async(
        phone_number,
        sms_body
      )
      save_notification(:sms, phone_number)
    end
  end

  def sms_body
    @sms_body ||= I18n.with_locale(:en) do
      I18n.t(
        'trailer_sensor_reading.notifier.sms_body',
        number: @trailer.registration_number,
        description: @trailer.description,
        sensor: @reading.sensor.translated_kind,
        value: @reading.value_text,
        treshold: @setting.warning_treshold_text
      )
    end
  end

  def save_notification(kind, contact_info)
    @reading.warning_notifications.create(
      sent_at: Time.current,
      kind: kind,
      contact_information: contact_info
    )
  end
end
