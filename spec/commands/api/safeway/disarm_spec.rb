require 'rails_helper'

RSpec.describe Api::Safeway::Disarm do
  describe '.call' do
    subject { described_class.call(trailer) }

    let(:trailer) { build(:trailer) }
    let(:websocket_double) { double('Websocket', broadcast: true) }

    before do
      allow(ActionCable).to receive(:server).and_return(websocket_double)
    end

    it 'sends arm: false signal to the device on the other end of websocket' do
      subject
      expect(websocket_double).to have_received(:broadcast).with("trailer_#{trailer.channel_uuid}", arm: false, subscribed_at: nil)
    end
  end
end
