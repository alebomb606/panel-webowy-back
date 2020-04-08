require 'rails_helper'

RSpec.describe TrailerDataChannel do

  subject(:channel) { described_class.new(connection, {}) }
  let(:current_trailer) { create(:trailer) }
  let(:connection) { ::ConnectionStubs::TestConnection.new(current_trailer: current_trailer) }
  let(:data) do
    {
      # 'command' => 'message',
      # 'identifier' => "channel: 'ActivePrintAppsChannel', uuid: #{current_trailer.channel_uuid}".to_json,
      # 'data' => {
        'action' => 'sensor_data',
        'payload' => {
          'trailer_temperature' => '20C',
          'safeway_battery_level' => '50%',
          'driver_panel_battery_level' => '45%',
          'data_transfer_limit' => '1248MB',
          'co2_level' => 'high',
          'tire_pressure_level' => 'low'
        }

      # }
    }
  end

  it 'calls proper data handler'  do
    expect(::TrailerConnection::HandleData).to receive(:new).exactly(1).times.and_call_original
    expect{ channel.perform_action(data) }.not_to raise_exception
  end

  it 'raises an error when the action type is unrecognised' do
    expect(::TrailerConnection::HandleData).to receive(:new).exactly(1).times.and_call_original
    expect{ channel.perform_action(data.merge('action' => 'execute_order_66')) }.to raise_exception(ChannelCommunicationError::UnsupportedActionType)
  end
end
