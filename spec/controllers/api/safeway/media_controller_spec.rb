require 'rails_helper'

RSpec.describe Api::Safeway::MediaController do
  before do
    set_jsonapi_headers
  end

  describe '#upload' do
    before do
      post :upload, params: params
    end

    let!(:device_media_file) { create(:device_media_file) }
    let(:file) { File.open(Rails.root.join('spec/support/icon.jpg')) }

    context 'with valid params' do
      let(:params) {
        {
          uuid: device_media_file.uuid,
          file: file,
          latitude: Faker::Address.latitude,
          longitude: Faker::Address.longitude,
          taken_at: 1.days.ago&.iso8601
        }
      }

      it 'returns 200 OK and returns a record' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      let(:params) {
        {
          uuid: SecureRandom.uuid,
          file: '',
          latitude: '',
          longitude: '',
          taken_at: ''
        }
      }

      it 'returns 422 and a list of errors' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with nonexistent UUID' do
      let(:params) {
        {
          uuid: SecureRandom.uuid,
          file: file,
          latitude: Faker::Address.latitude,
          longitude: Faker::Address.longitude,
          taken_at: 1.days.ago&.iso8601
        }
      }

      it 'returns 404 Not Found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
