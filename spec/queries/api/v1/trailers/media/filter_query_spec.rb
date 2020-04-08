require 'rails_helper'

RSpec.describe Api::V1::Trailers::Media::FilterQuery do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |r| r }
        m.failure(:trailer_not_found) { 'not found' }
        m.failure(:no_permission) { 'no permission' }
        m.failure { |r| r }
      end
    end

    let(:auth)    { create(:auth, :with_logistician) }
    let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }

    context 'with valid params' do
      context 'filter by dates' do
        let!(:media_file_1) { create(:device_media_file, trailer: trailer, requested_time: 30.minutes.ago) }
        let!(:media_file_2) { create(:device_media_file, trailer: trailer, requested_time: 29.minutes.ago) }
        let!(:media_file_3) { create(:device_media_file, trailer: trailer, requested_time: 28.minutes.ago) }
        let!(:media_file_4) { create(:device_media_file, trailer: trailer, requested_time: 10.minutes.ago) }

        let(:params) {
          {
            auth: auth,
            trailer_id: trailer.id,
            filter: {
              date_from: media_file_1.requested_time.iso8601,
              date_to: (media_file_1.requested_time + 5.minutes).iso8601
            }
          }
        }

        it 'returns records filtered by date' do
          expect(subject).to eq([media_file_3, media_file_2, media_file_1])
        end
      end

      context 'filter by cameras' do
        let!(:media_file_1) { create(:device_media_file, trailer: trailer, camera: :interior, requested_time: 12.days.ago) }
        let!(:media_file_2) { create(:device_media_file, trailer: trailer, camera: :exterior, requested_time: 8.days.ago) }
        let!(:media_file_3) { create(:device_media_file, trailer: trailer,  camera: :interior, requested_time: 5.days.ago) }
        let!(:media_file_4) { create(:device_media_file, trailer: trailer,  camera: :exterior, requested_time: 10.hours.ago) }

        let(:params) {
          {
            auth: auth,
            trailer_id: trailer.id,
            filter: {
              cameras: [media_file_1.camera, media_file_2.camera].join(',')
            }
          }
        }

        it 'returns records filtered by camera' do
          expect(subject).to eq([media_file_4, media_file_3])
        end
      end

      context 'filter by kinds' do
        let!(:media_file_1) { create(:device_media_file, trailer: trailer, kind: :photo,  requested_time: 12.days.ago) }
        let!(:media_file_2) { create(:device_media_file, trailer: trailer, kind: :video,  requested_time: 8.days.ago) }
        let!(:media_file_3) { create(:device_media_file, trailer: trailer, kind: :photo,  requested_time: 5.days.ago) }
        let!(:media_file_4) { create(:device_media_file, trailer: trailer, kind: :video,  requested_time: 10.hours.ago) }

        let(:params) {
          {
            auth: auth,
            trailer_id: trailer.id,
            filter: {
              kinds: media_file_1.kind
            }
          }
        }

        it 'returns records filtered by kind' do
          expect(subject).to eq([media_file_3])
        end
      end

      context 'filter by statuses' do
        let!(:media_file_1) { create(:device_media_file, trailer: trailer, status: :completed,  requested_time: 12.days.ago) }
        let!(:media_file_2) { create(:device_media_file, trailer: trailer, status: :completed,  requested_time: 8.days.ago) }
        let!(:media_file_3) { create(:device_media_file, trailer: trailer, status: :request,  requested_time: 5.days.ago) }
        let!(:media_file_4) { create(:device_media_file, trailer: trailer, status: :request,  requested_time: 10.hours.ago) }

        let(:params) {
          {
            auth: auth,
            trailer_id: trailer.id,
            filter: {
              kinds: [media_file_3.kind].join(',')
            }
          }
        }

        it 'returns records filtered by status' do
          expect(subject).to eq([media_file_4, media_file_3])
        end

      end

      context 'without specific permission' do
        let(:trailer) { create(:trailer) }
        let!(:perm)   { create(:trailer_access_permission, logistician: auth.logistician, trailer: trailer, monitoring_access: false) }
        let(:params)  { { auth: auth, trailer_id: trailer.id } }

        it 'returns no permission error' do
          expect(subject).to eq('no permission')
        end
      end
    end

    context 'without additional params' do
      let!(:media_file_1) { create(:device_media_file, trailer: trailer, requested_time: 12.days.ago) }
      let!(:media_file_2) { create(:device_media_file, trailer: trailer, requested_time: 8.days.ago) }
      let!(:media_file_3) { create(:device_media_file, trailer: trailer, requested_time: 5.days.ago) }
      let!(:media_file_4) { create(:device_media_file, trailer: trailer, requested_time: 10.hours.ago) }

      let(:params) { { auth: auth, trailer_id: trailer.id } }

      it 'returns media files taken up to 7 days' do
        expect(subject).to match_array([media_file_3, media_file_4])
      end
    end

    context 'with invalid params' do
      context 'with blank params' do
        let(:params) {
          {
            auth: auth,
            trailer_id: trailer.id,
            filter: {
              date_from: '',
              date_to: '',
            }
          }
        }

        let(:errors) { subject[:errors][:filter] }

        it 'returns errors' do
          expect(errors[:date_from]).to include(I18n.t('errors.filled?'))
          expect(errors[:date_to]).to include(I18n.t('errors.filled?'))
        end
      end

      context 'with from date after to date' do
        let(:params) {
          {
            trailer_id: trailer.id,
            filter: {
              date_from: Time.current.iso8601,
              date_to: 30.minutes.ago.iso8601
            }
          }
        }

        it 'returns errors' do
          expect(subject[:errors][:filter][:date_from]).to include(I18n.t('errors.from_before_to?'))
        end
      end

      context 'with invalid trailer ID' do
        let(:params)  { { auth: auth, trailer_id: -1 } }

        it 'returns error' do
          expect(subject).to eq('not found')
        end
      end

      context 'with one invalid camera' do
        let(:params) {
          {
            trailer_id: trailer.id,
            filter: {
              cameras: "non-existing, #{::DeviceMediaFile.cameras.keys.first}"
            }
          }
        }

        it 'returns errors' do
          expect(subject[:errors][:filter][:cameras][0]).to include(I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.cameras.keys.join(', ')))
        end
      end

      context 'with one invalid kind' do
        let(:params) {
          {
            trailer_id: trailer.id,
            filter: {
              kinds: "non-existing, #{::DeviceMediaFile.kinds.keys.first}"
            }
          }
        }

        it 'returns errors' do
          expect(subject[:errors][:filter][:kinds][0]).to include(I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.kinds.keys.join(', ')))
        end
      end

      context 'with one invalid status' do
        let(:params) {
          {
            trailer_id: trailer.id,
            filter: {
              statuses: "non-existing, #{::DeviceMediaFile.statuses.keys.first}"
            }
          }
        }

        it 'returns errors' do
          expect(subject[:errors][:filter][:statuses][0]).to include( I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.statuses.keys.join(', ')))
        end
      end
    end
  end
end
