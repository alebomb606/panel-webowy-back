require 'rails_helper'

shared_examples :notifiable do
  it 'creates email notification records' do
    expect { subject }.to change { ::WarningNotification.email.count }.by(2)
  end

  it 'creates sms notification records' do
    expect { subject }.to change { ::WarningNotification.sms.count }.by(1)
  end

  it 'saves email notification info' do
    expect(subject.warning_notifications.email.pluck(:contact_information)).to match_array(sensor_setting.email_addresses)
  end

  it 'saves sms notification info' do
    expect(subject.warning_notifications.sms.pluck(:contact_information)).to match_array(sensor_setting.phone_numbers)
  end

  it 'sends email notifications' do
    expect(::OldNotificationMailer).to receive(:sensor_alert).and_return(message_delivery).twice
    subject
  end

  it 'sends sms notifications' do
    expect(sms_sender).to receive(:perform_async).with(
      sensor_setting.phone_numbers.first,
      sms_body
    ).once
    subject
  end
end

shared_examples :non_notifiable do
  it 'does not send email notifications' do
    expect(::OldNotificationMailer).not_to receive(:sensor_alert)
    subject
  end

  it 'does not send sms notifications' do
    expect(sms_sender).not_to receive(:perform_async)
    subject
  end
end

RSpec.describe TrailerSensorReading::Notifier do
  describe '#call' do
    subject { described_class.new(reading).call }

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }
    let(:sms_sender)       { class_double(::Notification::SmsSenderWorker).as_stubbed_const }
    let(:sms_body) do
      I18n.with_locale(:en) do
        I18n.t(
          'trailer_sensor_reading.notifier.sms_body',
            number: reading.sensor.trailer.registration_number,
            description: reading.sensor.trailer.description,
            sensor: reading.sensor.translated_kind,
            value: reading.value_text,
            treshold: sensor_setting.warning_treshold_text
        )
      end
    end

    context 'with sensor alarm status' do
      context 'when send mail and sms is enabled' do
        let(:sensor)   { create(:trailer_sensor, kind: :trailer_temperature) }
        let!(:reading) { create(:trailer_sensor_reading, sensor: sensor, value: '-20', status: :alarm, read_at: 20.minutes.ago) }

        let!(:sensor_setting) {
          create(:trailer_sensor_setting,
            sensor: sensor,
            alarm_primary_value: 0,
            alarm_secondary_value: 50,
            warning_primary_value: 10,
            warning_secondary_value: 40,
            send_email: true,
            email_addresses: ['a@example.com', 'b@example.com'],
            send_sms: true,
            phone_numbers: ['123456789'],
            updated_at: 1.day.ago
          )
        }

        before do
          allow(message_delivery).to receive(:deliver_later).and_return(ActionMailer::DeliveryJob.new)
          allow(sms_sender).to receive(:perform_async).and_return(SecureRandom.hex)
        end

        it_behaves_like :notifiable

        context 'with new reading with same value' do
          let!(:reading_2) { create(:trailer_sensor_reading, sensor: sensor, value: reading.value, status: :alarm, read_at: 10.minutes.ago) }

          it_behaves_like :non_notifiable
        end

        context 'with subsequent warning reading' do
          let!(:reading_2) { create(:trailer_sensor_reading, sensor: sensor, value: -22, status: :alarm, read_at: 10.minutes.ago) }

          it_behaves_like :non_notifiable
        end

        context 'when previous reading value is ok' do
          let!(:reading_2) { create(:trailer_sensor_reading, sensor: sensor, value: -22, status: :ok, read_at: 10.minutes.ago) }

          it_behaves_like :notifiable
        end

        context 'when setting has been changed since last read' do
          let!(:reading_2) { create(:trailer_sensor_reading, sensor: sensor, value: -22, status: :alarm, read_at: 10.minutes.ago) }

          before { sensor_setting.touch }

          it_behaves_like :notifiable
        end
      end
    end

    context 'when sensor status is ok' do
      let(:sensor)  { create(:trailer_sensor, kind: :trailer_temperature) }
      let(:reading) { create(:trailer_sensor_reading, sensor: sensor, value: '100', status: :ok) }

      let!(:sensor_setting) {
        create(:trailer_sensor_setting,
          sensor: sensor,
          alarm_primary_value: 85,
          warning_primary_value: 50,
          send_email: true,
          email_addresses: ['a@example.com', 'b@example.com'],
          send_sms: true,
          phone_numbers: ['123456789'],
          updated_at: 1.day.ago
        )
      }

      it_behaves_like :non_notifiable
    end
  end
end
