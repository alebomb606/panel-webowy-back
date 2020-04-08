require 'rails_helper'

RSpec.describe TrailerConnection::HandleData do
  let(:trailer)      { create(:trailer) }
  let(:data_payload) {
    {
      'action' => 'sensor_data',
      'payload' => {
        'trailer_temperature' => '20C',
        'safeway_battery_level' => '50%',
        'driver_panel_battery_level' => '45%',
        'data_transfer_limit' => '1248MB',
        'co2_level' => 'high',
        'engine' => 'True'
      }
    }
  }

  describe 'initialize' do
    let(:subject)    { described_class.new(trailer, params) }

    context 'for valid input' do
      let(:params)   { data_payload.merge('action' => 'sensor_data') }

      it 'assigns proper data handler' do
        expect(subject.data_handler).to eq(::Api::Safeway::TrailerSensorReading::LogFromWebsocket)
      end
    end

    context 'for invalid input' do
      let(:params)   { data_payload.merge('action' => 'execute_order_66') }

      it 'raises proper error' do
        expect { subject }.to raise_error(ChannelCommunicationError::UnsupportedActionType)
      end
    end
  end

  describe 'call' do
    context 'for valid input' do
      subject { described_class.new(trailer, data_payload) }

      context 'for sensor_data' do
        it 'calls proper data handler' do
          expect(::Api::Safeway::TrailerSensorReading::LogFromWebsocket).to receive(:new).exactly(1).times.and_call_original
          subject.call
        end
      end

      context 'for gps_data' do
        before do
          data_payload.merge!('action' => 'gps_data')
        end

        it 'calls proper data handler' do
          expect(::Api::Safeway::RouteLog::LogFromWebsocket).to receive(:new).exactly(1).times.and_call_original
          subject.call
        end
      end

      context 'for event_data' do
        before do
          data_payload.merge!('action' => 'event_data')
        end

        it 'calls proper data handler' do
          expect(::Api::Safeway::TrailerEvent::LogFromWebsocket).to receive(:new).exactly(1).times.and_call_original
          subject.call
        end
      end
    end
  end
end
