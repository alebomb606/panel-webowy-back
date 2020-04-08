require 'rails_helper'

RSpec.describe Media::UploadWorker, type: :worker do
  describe '#perform' do
    subject { described_class.new.perform(media_file.id, file.path) }

    let!(:media_file) { create(:device_media_file) }
    let(:file)        { File.open(Rails.root.join('spec/support/icon.jpg')) }
    let(:serialized_media) {
      {
        data: [{
          type: 'trailer_media',
          attributes: {
            status: 'completed'
          }
        }]
      }
    }

    it 'does not create a device_media_file object' do
      expect { subject }.not_to change { DeviceMediaFile.count }
    end

    it 'saves a file to the device_media_file object' do
      expect { subject }.to change { media_file.reload.file }
    end

    it 'changes device_media_file status to completed' do
      expect { subject }.to change { media_file.reload.status }.to('completed')
    end

    it 'triggers the ActionCable to send message to the logistician' do
      expect { subject }.to have_broadcasted_to("auths_#{media_file.logistician.auth.id}")
        .with(include_json(serialized_media))
    end
  end
end
