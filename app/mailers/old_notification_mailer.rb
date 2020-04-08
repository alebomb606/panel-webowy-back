class OldNotificationMailer < ApplicationMailer
  def sensor_alert(reading_id, email)
    @reading = ::TrailerSensorReading.find(reading_id)
    @sensor  = @reading.sensor
    trailer  = @sensor.trailer

    I18n.with_locale(:en) do
      mail(
        to: email,
        subject: t('.subject', number: trailer.registration_number, description: trailer.description)
      )
    end
  end
end
