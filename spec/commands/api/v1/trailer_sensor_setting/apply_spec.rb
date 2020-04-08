require 'rails_helper'

RSpec.describe Api::V1::TrailerSensorSetting::Apply do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |res| res }
        m.failure(:no_permission) { 'no permission' }
        m.failure(:setting_not_found) { 'setting not found' }
        m.failure(:trailer_not_found) { 'no permission' }
        m.failure { |res| res }
      end
    end

    let(:auth)     { create(:auth, :with_logistician) }
    let(:trailer)  { create(:trailer, :with_permission, permission_logistician: auth.logistician) }
    let(:sensor)   { create(:trailer_sensor, trailer: trailer, kind: :trailer_temperature, status: :ok, value_percentage: 20) }
    let(:setting)  { create(:trailer_sensor_setting, sensor: sensor) }
    let(:base_params) {
      {
        alarm_primary_value: 10,
        alarm_secondary_value: 30,
        warning_primary_value: 20,
        warning_secondary_value: 25,
        send_sms: true,
        send_email: false,
        phone_numbers: ['50555555555', '48666666666'],
        email_addresses: ['a@example.com', 'b@example.com']
      }
    }

    context 'with valid params' do
      let(:params) { base_params.merge(auth: auth, id: setting.id) }

      context 'with reading' do
        let!(:reading) { create(:trailer_sensor_reading, sensor: sensor, original_value: 9, value: 9) }

        it 'updates values' do
          expect(subject).to have_attributes(base_params)
        end

        it 'updates sensor state' do
          subject
          expect(sensor.reload).to have_attributes(status: 'alarm', value_percentage: 0)
        end
      end

      context 'with no reading' do
        it 'updates values' do
          expect(subject).to have_attributes(base_params)
        end

        it 'does not update sensor state' do
          expect { subject }.not_to change { sensor.reload.attributes }
        end
      end

      context 'for data transfer sensor' do
        let(:params)  { base_params.merge('auth' => auth, 'id' => setting.id.to_s, 'alarm_primary_value' => '3.5', 'warning_primary_value' => '5.5') }
        let(:sensor)  { create(:trailer_sensor, trailer: trailer, kind: :data_transfer) }
        let(:setting) { create(:trailer_sensor_setting, sensor: sensor) }

        it 'updates values' do
          expect(subject).to have_attributes(
            alarm_primary_value: 3.5,
            warning_primary_value: 5.5,
            alarm_secondary_value: nil,
            warning_secondary_value: nil
          )
        end
      end
    end

    context 'with invalid params' do
      let(:errors) { subject[:errors] }

      context 'percentage sensor' do
        let(:sensor)  { create(:trailer_sensor, trailer: trailer, kind: :safeway_battery) }
        let(:setting) { create(:trailer_sensor_setting, sensor: sensor) }

        let(:params) {
          {
            auth: auth,
            id: setting.id,
            alarm_primary_value: -10,
            warning_primary_value: 101
          }
        }

        it 'returns errors' do
          expect(errors[:alarm_primary_value]).to include(I18n.t('errors.gteq?', num: 0))
          expect(errors[:warning_primary_value]).to include(I18n.t('errors.lteq?', num: 100))
        end
      end

      context 'data transfer sensor' do
        let(:sensor)   { create(:trailer_sensor, trailer: trailer, kind: :data_transfer) }
        let(:setting)  { create(:trailer_sensor_setting, sensor: sensor) }

        let(:params) {
          {
            auth: auth,
            id: setting.id,
            alarm_primary_value: '-10',
            warning_primary_value: '-5'
          }
        }

        it 'returns errors' do
          expect(errors[:alarm_primary_value]).to include(I18n.t('errors.gt?', num: 0))
          expect(errors[:warning_primary_value]).to include(I18n.t('errors.gt?', num: 0))
        end

        context 'with alarm_primary_value > warning_primary_value' do
          let(:params) { { auth: auth, id: setting.id, alarm_primary_value: 15, warning_primary_value: 11 } }

          it 'returns errors' do
            expect(errors[:warning_primary_value]).to include(I18n.t('errors.gteq?', num: 15.0))
          end
        end
      end

      context 'when send_email is true but emails are empty' do
        let(:params) { base_params.merge(auth: auth, id: setting.id, email_addresses: [], send_email: true) }

        it 'returns error' do
          expect(errors[:email_addresses]).to include(I18n.t('errors.filled?'))
        end
      end

      context 'without assigned permission' do
        let(:trailer)  { create(:trailer) }
        let(:sensor)   { create(:trailer_sensor, trailer: trailer) }
        let(:setting)  { create(:trailer_sensor_setting, sensor: sensor) }
        let(:params)   { { auth: auth, id: setting.id, alarm_primary_value: 10, warning_primary_value: 5 } }

        it 'returns error' do
          expect(subject).to eq('no permission')
        end
      end

      context 'without specific access permission' do
        let(:trailer)  { create(:trailer) }
        let(:sensor)   { create(:trailer_sensor, trailer: trailer) }
        let!(:perm)    { create(:trailer_access_permission, trailer: trailer, logistician: auth.logistician, sensor_access: false) }
        let(:setting)  { create(:trailer_sensor_setting, sensor: sensor) }
        let(:params)   { { auth: auth, id: setting.id, alarm_primary_value: 10, warning_primary_value: 5 } }

        it 'returns error' do
          expect(subject).to eq('no permission')
        end
      end

      context 'with invalid Setting ID' do
        let(:params) { { auth: auth, id: -1, alarm_primary_value: 10, warning_primary_value: 5 } }

        it 'returns error' do
          expect(subject).to eq('setting not found')
        end
      end

      context 'with missing values' do
        let(:params) { { auth: auth, id: setting.id, alarm_primary_value: nil, warning_primary_value: nil } }

        it 'returns errors' do
          expect(errors[:alarm_primary_value]).to include(I18n.t('errors.filled?'))
          expect(errors[:warning_primary_value]).to include(I18n.t('errors.filled?'))
        end
      end

      context 'when alarm range is not in allowed range' do
        let(:params) {
          {
            auth: auth,
            id: setting.id,
            alarm_primary_value: -100,
            alarm_secondary_value: 100,
            warning_primary_value: -50,
            warning_secondary_value: 50
          }
        }

        it 'returns errors' do
          expect(errors[:alarm_primary_value]).to include(I18n.t('errors.gteq?', num: -35))
          expect(errors[:alarm_secondary_value]).to include(I18n.t('errors.lteq?', num: 60))
        end
      end

      context 'when alarm primary > alarm secondary' do
        let(:params) { { auth: auth, id: setting.id, warning_primary_value: 13, warning_secondary_value: 15, alarm_primary_value: 20, alarm_secondary_value: 19 } }

        it 'returns error' do
          expect(errors[:alarm_primary_value]).to include(I18n.t('errors.lt?', num: 19.0))
        end
      end

      context 'when warning primary > warning secondary' do
        let(:params) { { auth: auth, id: setting.id, warning_primary_value: 12, warning_secondary_value: 11, alarm_primary_value: 10, alarm_secondary_value: 20 } }

        it 'returns error' do
          expect(errors[:warning_primary_value]).to include(I18n.t('errors.lt?', num: 11.0))
        end
      end

      context 'when warning range is not in alarm range' do
        let(:params) { { auth: auth, id: setting.id, alarm_primary_value: -30, alarm_secondary_value: 30, warning_primary_value: -60, warning_secondary_value: 70 } }

        it 'returns errors' do
          expect(errors[:warning_primary_value]).to include(I18n.t('errors.gt?', num: -30.0))
          expect(errors[:warning_secondary_value]).to include(I18n.t('errors.lt?', num: 30.0))
        end
      end

      context 'when one of filled numbers is not in E.164 format' do
        let(:params) {
          {
            auth: auth,
            id: setting.id,
            alarm_primary_value: -30,
            warning_primary_value: -20,
            send_sms: true,
            phone_numbers: ['+44555555555', '555 555 555']
          }
        }

        it 'returns errors' do
          expect(errors[:phone_numbers][1]).to include(I18n.t('errors.phone_number?'))
        end
      end
    end
  end
end
