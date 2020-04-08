require 'rails_helper'

RSpec.describe Api::Safeway::TrailerEvent::LogFromWebsocket do
  describe '#call' do
    subject do
      described_class.new.call(trailer, params) do |m|
        m.success { |trailer| trailer }
        m.failure { |res| res }
      end
    end

    let!(:trailer) { create(:trailer, status: :start_loading) }
    let!(:event)   { create(:trailer_event, trailer: trailer, kind: :start_loading) }

    context 'with valid params' do
      let(:new_event) { subject.events.find_by(uuid: data_1['uuid']) }
      let(:data_1) {
        {
          type: 'alarm',
          'gps' => { 'latitude' => Faker::Address.latitude.to_s, 'longitude' => Faker::Address.longitude.to_d },
          date: Faker::Time.between(Date.today, 1.week.from_now, :day).to_f,
          sensor: 'manual',
          'uuid' => SecureRandom.uuid
        }
      }

      context 'with hash as input' do
        let(:params) { data_1 }

        it 'creates new trailer_events records' do
          expect { subject }.to change { ::TrailerEvent.count }.by(2)
        end

        it 'saves data for new event with accompanying route_log' do
          expect(new_event).to have_attributes(
            kind: data_1[:type],
            triggered_at: Time.zone.at(data_1[:date]),
            sensor_name: data_1[:sensor]
          )
          expect(new_event.route_log).to have_attributes(
            latitude: BigDecimal(data_1['gps']['latitude'].to_s).round(6),
            longitude: BigDecimal(data_1['gps']['longitude'].to_s).round(6)
          )
        end
      end

      # This feature is unused
      context 'with array as input' do
        let!(:logistician_1) { create(:logistician, :with_auth) }
        let!(:logistician_2) { create(:logistician, :with_auth) }

        let(:serialized_event) do
          {
            data: [{
              type: 'trailer_event',
              attributes: {}
            }]
          }
        end

        let(:serialized_trailer) do
          {
            data: [{
              type: 'trailer',
              attributes: {}
            }]
          }
        end

        let(:data_2) {
          {
            type: 'disarmed',
            'gps' => { 'latitude' => Faker::Address.latitude.to_d, 'longitude' => Faker::Address.longitude.to_d },
            date: Faker::Time.between(Date.today, 1.week.from_now, :day).to_f,
            sensor: 'manual',
            'uuid' => event.uuid
          }
        }
        let(:data_3) {
          {
            type: 'armed',
            'gps' => { 'latitude' => Faker::Address.latitude.to_d, 'longitude' => Faker::Address.longitude.to_d },
            date: Faker::Time.between(Date.today, 1.week.from_now, :day).to_f,
            sensor: 'manual',
            'uuid' => SecureRandom.uuid
          }
        }

        let(:params) { [data_1, data_2, data_3] }

        before do
          create(:trailer_access_permission, trailer: trailer, logistician: logistician_1)
          create(:trailer_access_permission, trailer: trailer, logistician: logistician_2)
        end

        it 'creates new trailer_event records' do
          expect { subject }.to change { ::TrailerEvent.count }.by(3)
        end

        it 'creates media file for alarm event' do
          expect { subject }.to change { ::DeviceMediaFile.count }.by(1)
        end

        it 'does not update data for existing event' do
          expect { subject }.not_to change { event.reload.attributes }
        end

        it 'saves data for new event' do
          expect(new_event).to have_attributes(
            kind: data_1[:type],
            triggered_at: Time.zone.at(data_1[:date]),
            sensor_name: data_1[:sensor]
          )
          expect(new_event.route_log).to have_attributes(
            latitude: BigDecimal(data_1['gps']['latitude'].to_s).round(6),
            longitude: BigDecimal(data_1['gps']['longitude'].to_s).round(6)
          )
        end

        it 'saves media file for alarm event' do
          subject
          expect(::DeviceMediaFile.last).to have_attributes(
            kind: 'photo',
            status: 'request',
            camera: 'interior',
            trailer_event: new_event
          )
        end

        it 'broadcast WS message to Safeway device' do
          expect { subject }.to have_broadcasted_to("trailer_#{trailer.channel_uuid}").with(loading: false, subscribed_at: nil)
            .and have_broadcasted_to("trailer_#{trailer.channel_uuid}").with(include_json(kind: 'photo'))
        end

        it 'broadcasts WS message to logistician_1' do
          expect { subject }.to  have_broadcasted_to("auths_#{logistician_1.auth.id}").with(include_json(serialized_event)).exactly(3).times
            .and have_broadcasted_to("auths_#{logistician_1.auth.id}").with(include_json(serialized_trailer)).once
        end

        it 'broadcasts WS message to logistician_2' do
          expect { subject }.to  have_broadcasted_to("auths_#{logistician_2.auth.id}").with(include_json(serialized_event)).exactly(3).times
            .and have_broadcasted_to("auths_#{logistician_2.auth.id}").with(include_json(serialized_trailer)).once
        end

        it 'updates trailer status' do
          expect { subject }.to change { trailer.status }.to('armed')
        end

        context 'with date as int' do
          let(:params) { [data_1] }

          before do
            data_1.merge!(date: Faker::Time.between(1.year.ago, Date.today, :day).to_i)
          end

          it 'creates new trailer_event record' do
            expect { subject }.to change { ::TrailerEvent.count }.by(2)
          end
        end
      end
    end

    let(:errors) { subject[:errors] }

    context 'with empty attributes' do
      let(:params) {
        [
          {
            type: '',
            gps: nil,
            date: '',
            sensor: ''
          }
        ]
      }

      it 'does not create new trailer_event record' do
        expect { subject }.not_to change { ::TrailerEvent.count }
      end

      it 'returns errors' do
        expect(errors[0][:type]).to include(I18n.t('errors.filled?'))
        expect(errors[0][:date]).to include(I18n.t('errors.filled?'))
      end
    end

    context 'with invalid type selected' do
      let(:params) {
        [
          {
            type: 'xyzabc',
            gps: { latitude: Faker::Address.latitude.to_d, longitude: Faker::Address.longitude.to_d },
            date: Faker::Time.between(1.year.ago, Date.today, :day).to_i,
            sensor: 'manual'
          }
        ]
      }

      it 'returns error' do
        expect(errors[0][:type]).to include(I18n.t('errors.included_in?.arg.default', list: ::TrailerEvent.kinds.keys.join(', ')))
      end
    end

    context 'with invalid coordinates passed' do
      let(:params) {
        [
          {
            type: ::TrailerEvent.kinds.keys.sample,
            gps: { latitude: -95.to_d, longitude: 190.to_d },
            date: Faker::Time.between(1.year.ago, Date.today, :day).to_f,
            sensor: 'manual',
            uuid: SecureRandom.uuid
          }
        ]
      }

      it 'does not create new trailer_event record' do
        expect { subject }.not_to change { ::TrailerEvent.count }
      end

      it 'returns errors' do
        expect(errors[0][:gps][:latitude]).to include(I18n.t('errors.latitude?'))
        expect(errors[0][:gps][:longitude]).to include(I18n.t('errors.longitude?'))
      end
    end

    context 'with empty array' do
      let(:params) { [] }

      it 'returns errors' do
        expect(errors).to include(I18n.t('errors.filled?'))
      end
    end
  end
end
