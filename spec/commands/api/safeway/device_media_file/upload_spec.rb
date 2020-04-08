require 'rails_helper'

RSpec.describe Api::Safeway::DeviceMediaFile::Upload do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success {}
        m.failure(:not_found) { 'media file not found' }
        m.failure { |res| res }
      end
    end

    let!(:device_media_file) { create(:device_media_file) }
    let(:file) { File.open(Rails.root.join('spec/support/icon.jpg')) }

    context 'with valid params' do
      let(:params) {
        {
          uuid: device_media_file.uuid,
          file: file,
          latitude: device_media_file.route_log.latitude,
          longitude: device_media_file.route_log.longitude,
          taken_at: 1.days.ago&.iso8601
        }
      }
      let(:serialized_media) {
        {
          data: [{
            type: 'trailer_media',
            attributes: {
              status: 'processing'
            }
          }]
        }
      }

      it 'does not create a device_media_file record' do
        expect { subject }.not_to change { ::DeviceMediaFile.count }
      end

      it 'creates a RouteLog object' do
        expect { subject }.to change { ::RouteLog.count }.by(1)
      end

      #it 'enqueues Sidekiq job to upload the file' do
      #  expect(Media::UploadWorker).to receive(:perform_async).with(device_media_file.id, file.path)
      #  subject
      #end

      #it 'triggers the ActionCable to send message to the logistician' do
      #  expect { subject }.to have_broadcasted_to("auths_#{device_media_file.logistician.auth.id}")
      #    .with(include_json(serialized_media))
      #end
    end

    context 'with empty attributes' do
      let(:params)  {
        attributes_for(:device_media_file,
          file: '',
          uuid: '',
          latitude: '',
          longitude: '',
          taken_at: ''
        )
      }
      let(:errors)  { subject[:errors] }

      it 'does not update device_media_file :file attribute' do
        expect { subject }.not_to change { device_media_file }
      end

      it 'returns errors' do
        expect(errors).to include(:uuid, :file, :latitude, :longitude)
        expect(errors[:latitude]).to include(I18n.t('errors.filled?'))
        expect(errors[:longitude]).to include(I18n.t('errors.filled?'))
        expect(errors[:taken_at]).to include(I18n.t('errors.filled?'))
      end

      it 'does not create a RouteLog object' do
        expect { subject }.not_to change { ::RouteLog.count }
      end

      it 'does not change the device_media_file status' do
        expect { subject }.not_to change { device_media_file.reload.status }
      end
    end

    context 'when media uuid cant be found' do
      let(:params)  {
        attributes_for(:device_media_file,
          uuid: 'qwerty',
          file: file,
          latitude: device_media_file.route_log.latitude,
          longitude: device_media_file.route_log.longitude,
          taken_at: 1.days.ago&.iso8601
        )
      }
      let(:errors)  { subject[:errors] }

      it 'does not update device_media_file :file attribute' do
        expect { subject }.not_to change { device_media_file.file }
      end

      it 'returns errors' do
        expect(subject).to eq('media file not found')
      end

      it 'does not create a RouteLog object' do
        expect { subject }.not_to change { ::RouteLog.count }
      end

      it 'does not change the device_media_file status' do
        expect { subject }.not_to change { device_media_file.reload.status }
      end
    end
  end
end
