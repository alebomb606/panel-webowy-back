require 'rails_helper'

RSpec.describe MasterAdmin::Trailer::Camera::MountAvailable do
  describe '#call' do
    subject do
      described_class.new.call(params)
    end

    context 'call' do
      let!(:trailer) { create(:trailer) }
      let(:params) { trailer }

      it 'mount cameras' do
        subject
        expect(::TrailerCamera.count).to eq ::TrailerCamera.camera_types.keys.count
      end
    end
  end
end
