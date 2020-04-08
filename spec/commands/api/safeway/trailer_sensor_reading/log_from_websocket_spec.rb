require 'rails_helper'

RSpec.describe Api::Safeway::TrailerSensorReading::LogFromWebsocket do
  describe '#call' do
    subject do
      described_class.new.call(trailer, params) do |m|
        m.success { }
        m.failure(:sensor_not_found) { 'sensor not found' }
        m.failure { |res| res }
      end
    end

    let!(:trailer) { create(:trailer, status: :end_loading) }

    let!(:temperature_sensor)   { create(:trailer_sensor, :with_setting, trailer: trailer, kind: :trailer_temperature, status: :ok) }
    let!(:battery_panel_sensor) { create(:trailer_sensor, :with_setting, trailer: trailer, kind: :driver_panel_battery, status: :ok) }
    let!(:co2_sensor)           { create(:trailer_sensor, :with_setting, trailer: trailer, kind: :co2, status: :ok) }
    let!(:transfer_sensor)      { create(:trailer_sensor, :with_setting, trailer: trailer, kind: :data_transfer, status: :ok) }
    let!(:truck_battery_sensor) { create(:trailer_sensor, :with_setting, trailer: trailer, kind: :truck_battery, status: :ok) }
    let!(:logistician_1)        { create(:logistician, :with_auth) }
    let!(:permission)           { create(:trailer_access_permission, trailer: trailer, logistician: logistician_1) }

    context 'with valid params' do
      let!(:battery_sensor)       { create(:trailer_sensor, :with_setting, trailer: trailer, kind: :safeway_battery, status: :ok) }

      let(:params) {
        {
          truck_temperature:          Faker::Number.number(2),
          battery:                    Faker::Number.number(2),
          driver_panel_battery_level: Faker::Number.number(2),
          data_available:             4,
          data_used:                  2,
          co2:                        Faker::Number.number(2),
          truck_battery_level:        Faker::Number.number(2)
        }
      }

      let!(:logistician_2) { create(:logistician, :with_auth) }

      let(:serialized_sensors) {
        trailer.sensors.map do |sensor|
          {
            id: sensor.id.to_s,
            type: 'trailer_sensor',
            attributes: {
              kind: sensor.kind
            }
          }
        end
      }

      before do
        create(:trailer_access_permission, trailer: trailer, logistician: logistician_2)
      end

      it 'creates sensor readings' do
        expect { subject }.to change { ::TrailerSensorReading.count }.by(6)
      end

      it 'update sensors values' do
        subject
        expect(temperature_sensor.reload.value).to eq(params[:truck_temperature].to_f)
        expect(battery_sensor.reload.value).to eq(params[:battery].to_f)
        expect(battery_panel_sensor.reload.value).to eq(params[:driver_panel_battery_level].to_f)
        expect(transfer_sensor.reload.value).to eq((params[:data_available] - params[:data_used]).to_f)
        expect(co2_sensor.reload.value).to eq(params[:co2].to_f)
        expect(truck_battery_sensor.reload.value).to eq(params[:truck_battery_level].to_f)
      end

      it 'sends WS message to logistician_1' do
        expect { subject }.to have_broadcasted_to("auths_#{logistician_1.auth.id}")
          .with(include_json(data: UnorderedArray(*serialized_sensors)))
          .once
      end

      it 'sends WS message to logistician_2' do
        expect { subject }.to have_broadcasted_to("auths_#{logistician_2.auth.id}")
          .with(include_json(data: UnorderedArray(*serialized_sensors)))
          .once
      end
    end

    context 'with alarming reading' do
      let!(:battery_sensor) { create(:trailer_sensor, trailer: trailer, kind: :safeway_battery, status: :ok) }
      let!(:setting)        { create(:trailer_sensor_setting, sensor: battery_sensor, alarm_primary_value: 15, warning_primary_value: 20, updated_at: 1.day.ago) }
      let(:params)          { { battery: 10 } }

      let(:trailer_websocket_data) do
        {
          data: [
            {
              type: 'trailer',
              attributes: {}
            }
          ]
        }
      end

      it 'updates trailer status to alarm' do
        expect { subject }.to change { trailer.reload.status }.to('alarm')
      end

      it 'logs alarm event' do
        expect { subject }.to change { ::TrailerEvent.count }.by(1)
        expect(::TrailerEvent.alarm.count).to eq(1)
      end

      it 'broadcasts WS message with trailer data' do
        expect { subject }.to have_broadcasted_to("auths_#{logistician_1.auth.id}")
          .with(include_json(trailer_websocket_data))
      end

      context 'with subsequent alarm reading' do
        before { described_class.new.call(trailer, params) }

        it 'does not change trailer status' do
          expect { subject }.not_to change { trailer.reload.status }
        end

        it 'does not log same kind of event again' do
          expect { subject }.not_to change { ::TrailerEvent.count }
        end

        it 'does not broadcast WS message with trailer data' do
          expect { subject }.not_to have_broadcasted_to("auths_#{logistician_1.auth.id}")
            .with(include_json(trailer_websocket_data))
        end
      end
    end

    context 'with data used but no data available' do
      let(:params) {
        {
          data_used: 4,
          data_available: nil
        }
      }

      it 'returns errors' do
        expect(subject[:errors][:data_available]).to include(I18n.t('errors.filled?'))
      end

      it 'does not send any WS message' do
        expect { subject }.not_to have_broadcasted_to("auths_#{logistician_1.auth.id}")
      end
    end

    context 'when only some of the sensors are supplied' do
      let!(:battery_sensor) { create(:trailer_sensor, :with_setting, trailer: trailer, kind: :safeway_battery, status: :ok) }

      let(:params) {
        {
          battery: Faker::Number.number(2),
          co2: Faker::Number.number(2)
        }
      }

      let(:serialized_sensors) {
        [
          {
            id: battery_sensor.id.to_s,
            type: 'trailer_sensor',
            attributes: {
              kind: battery_sensor.kind
            }
          },
          {
            id: co2_sensor.id.to_s,
            type: 'trailer_sensor',
            attributes: {
              kind: co2_sensor.kind
            }
          }
        ]
      }

      it 'updates given sensors' do
        subject
        expect(battery_sensor.reload.value).to eq(params[:battery].to_f)
        expect(co2_sensor.reload.value).to eq(params[:co2].to_f)
      end

      it 'sends WS message to logistician_1' do
        expect { subject }.to have_broadcasted_to("auths_#{logistician_1.auth.id}")
          .with(include_json(data: UnorderedArray(*serialized_sensors)))
          .once
      end
    end

    context 'when sensor is not defined' do
      let(:params) { { battery: Faker::Number.number(2) } }

      it 'returns not found' do
        expect(subject).to eq('sensor not found')
      end
    end
  end
end
