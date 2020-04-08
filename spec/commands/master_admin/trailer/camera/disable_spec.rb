require 'rails_helper'

RSpec.describe MasterAdmin::Trailer::Camera::Disable do
  describe '#call' do
    subject do
      described_class.new.call(params) do |r|
        r.success {}
        r.failure(:not_found) { 'Not found' }
      end
    end

    context 'when camera does not exist' do
      let(:params) { -5 }

      it 'stops the procedure at finding the camera' do
        expect(subject).to eq 'Not found'
      end
    end

    context 'when camera exists' do
      let!(:trailer) { create(:trailer) }
      let!(:trailer_camera) { create(:trailer_camera, installed_at: 10.days.ago, trailer_id: trailer.id) }
      let(:params) { trailer_camera.id }

      it 'changes the installed at timestamp' do
        subject
        expect(trailer_camera.reload.installed_at).to be_nil
      end
    end
  end
end
