require 'rails_helper'

RSpec.describe Api::Safeway::TrailerRecordingList::LogFromWebsocket do
  describe '#call' do
    subject do
      described_class.new.call(trailer, params)
    end

    let!(:trailer) { create(:trailer) }

    context 'with valid params' do
      let(:params) { JSON.parse(File.read(File.join(Rails.root, '/spec/support/recording_list.json'))) }

      it 'updates recording_list attributes' do
        subject
        expect(trailer.reload.recording_list).to eq(params)
      end
    end
  end
end
