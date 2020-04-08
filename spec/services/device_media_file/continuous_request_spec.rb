require 'rails_helper'

RSpec.describe DeviceMediaFile::ContinuousRequest do
  let!(:trailer_1) { create(:trailer, :with_cameras) }
  let!(:trailer_2) { create(:trailer, :with_installed_cameras) }
  let!(:trailer_3) { create(:trailer, :with_cameras, :archived) }

  subject { described_class.new.call }

  describe '#call' do
    context '#call' do
      it 'creates media requests for available cameras from active trailers' do
        expect { subject }.to change { ::DeviceMediaFile.count }.by(6)
      end
    end
  end
end
