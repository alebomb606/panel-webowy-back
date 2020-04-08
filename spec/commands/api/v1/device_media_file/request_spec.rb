require 'rails_helper'

RSpec.describe Api::V1::DeviceMediaFile::Request do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |res| res }
        m.failure(:trailer_not_found) { 'trailer not found' }
        m.failure(:logistician_not_found) { 'logistician not found' }
        m.failure(:no_permission) { 'no permission' }
        m.failure { |res| res }
      end
    end

    let(:logistician) { create(:logistician, :with_auth) }
    let(:trailer)     { create(:trailer, :with_permission, permission_logistician: logistician) }

    context 'with valid params' do
      let(:params) { attributes_for(:device_media_file, trailer_id: trailer.id, auth: logistician.auth) }
      let(:serialized_media) {
        {
          data: [{
            type: 'trailer_media',
            attributes: {
              status: 'request'
            }
          }]
        }
      }

      it 'creates new device_media_file record' do
        expect { subject }.to change { ::DeviceMediaFile.count }.by(1)
      end

      it 'the device_media_file record has request status' do
        expect(subject.status).to eq('request')
      end

      it 'triggers the ActionCable to send message to the trailer' do
        expect { subject }.to have_broadcasted_to("trailer_#{trailer.channel_uuid}")
      end
    end

    context 'with empty attributes' do
      let(:params)  {
        attributes_for(:device_media_file,
          trailer_id: trailer.id,
          requested_at: '',
          requested_time: '',
          kind: '',
          status: '',
          auth: nil
        )
      }
      let(:errors)  { subject[:errors] }

      it 'does not create new device_media_file record' do
        expect { subject }.not_to change { ::DeviceMediaFile.count }
      end

      it 'returns errors' do
        expect(errors).to include(:requested_at, :kind, :requested_time)
        expect(errors[:requested_at]).to include(I18n.t('errors.filled?'))
        expect(errors[:requested_time]).to include(I18n.t('errors.filled?'))
        expect(errors[:kind]).to include(I18n.t('errors.filled?'))
      end
    end

    context 'when requesting photo and has no photo download permission' do
      let(:trailer)     { create(:trailer) }
      let!(:permission) { create(:trailer_access_permission, photo_download: false, trailer: trailer, logistician: logistician) }
      let(:params)      { attributes_for(:device_media_file, kind: 'photo', trailer_id: trailer.id, auth: logistician.auth) }

      it 'returns no permission failure' do
        expect(subject).to eq('no permission')
      end
    end

    context 'when requesting video and has no video download permission' do
      let(:trailer)     { create(:trailer) }
      let!(:permission) { create(:trailer_access_permission, video_download: false, trailer: trailer, logistician: logistician) }
      let(:params)      { attributes_for(:device_media_file, kind: 'video', trailer_id: trailer.id, auth: logistician.auth) }

      it 'returns no permission failure' do
        expect(subject).to eq('no permission')
      end
    end

    context 'with non-existing trailer' do
      let(:params) { attributes_for(:device_media_file, trailer_id: -1, auth: logistician.auth) }

      it 'returns not found Failure' do
        expect(subject).to eq('trailer not found')
      end
    end

    context 'with trailer not assigned to logistician' do
      let(:trailer) { create(:trailer) }
      let(:params)  { attributes_for(:device_media_file, trailer_id: trailer.id, auth: logistician.auth) }

      it 'returns not found Failure' do
        expect(subject).to eq('trailer not found')
      end
    end

    context 'with invalid kind selected' do
      let(:params) { attributes_for(:device_media_file, trailer_id: trailer.id, auth: logistician.auth, kind: :xyzabc) }
      let(:errors) { subject[:errors] }

      it 'returns error' do
        expect(errors[:kind]).to include(I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.kinds.keys.join(', ')))
      end
    end

    context 'with invalid camera selected' do
      let(:params) { attributes_for(:device_media_file, trailer_id: trailer.id, auth: logistician.auth, camera: :xyzabc) }
      let(:errors) { subject[:errors] }

      it 'returns error' do
        expect(errors[:camera]).to include(I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.cameras.keys.join(', ')))
      end
    end
  end
end
