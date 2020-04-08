require 'rails_helper'

RSpec.describe Api::Safeway::RequestMedia do
  describe '.call' do
    subject { described_class.call(trailer, attributes) }

    let(:trailer) { build(:trailer) }
    let(:attributes) {
      {
        uuid: SecureRandom.uuid,
        camera: 'left_top',
        requested_time: Time.current,
        kind: 'photo'
      }
    }
    let(:processed_attributes) {
      {
        url: "https://#{Rails.application.secrets.host}/api/safeway/media/#{attributes[:uuid]}/upload",
        failure_url: "https://#{Rails.application.secrets.host}/api/safeway/media/#{attributes[:uuid]}/failure",
        camera: attributes[:camera],
        time: attributes[:requested_time].to_i,
        kind: attributes[:kind],
        alarm: false,
        subscribed_at: nil
      }
    }
    let(:websocket_double) { double('Websocket', broadcast: true) }

    before do
      allow(ActionCable).to receive(:server).and_return(websocket_double)
    end

    it 'sends requestMedia signal to the device on the other end of websocket' do
      subject
      expect(websocket_double).to have_received(:broadcast).with("trailer_#{trailer.channel_uuid}", processed_attributes)
    end
  end
end
