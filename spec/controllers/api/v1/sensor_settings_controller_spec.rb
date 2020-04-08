require 'rails_helper'

RSpec.describe Api::V1::SensorSettingsController do
  let!(:auth) { create(:auth, :with_logistician) }

  before do
    set_jsonapi_headers
    set_auth_headers(auth)
  end

  let(:sensor)  { create(:trailer_sensor, trailer: trailer, kind: :trailer_temperature) }
  let(:setting) { create(:trailer_sensor_setting, sensor: sensor) }

  describe 'PATCH #apply' do
    let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }
    let(:data) {
      {
        type: 'trailer_sensor_setting',
        id: setting.id.to_s,
        attributes: {
          alarm_primary_value: 0,
          alarm_secondary_value: 10,
          warning_primary_value: 5,
          warning_secondary_value: 6,
          send_email: true,
          send_sms: true,
          email_addresses: ['a@example.com'],
          phone_numbers: ['48555555555']
        }
      }
    }

    context 'with valid setting ID' do
      let(:params) {
        {
          id: setting.id,
          _jsonapi: {
            data: data
          }
        }
      }

      let(:included_data) {
        [
          {
            id: sensor.id.to_s,
            type: 'trailer_sensor',
            attributes: {
              status: sensor.status,
              value: sensor.value,
              kind: sensor.kind,
            }
          }
        ]
      }

      before do
        patch :update, params: params
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns updated record' do
        expect(parsed_response_body[:data]).to include_json(data)
      end

      it 'returns included data' do
        expect(parsed_response_body[:included].count).to eq(1)
        expect(parsed_response_body[:included]).to include_json(included_data)
      end
    end

    context 'without specific access permission' do
      let(:trailer) { create(:trailer) }
      let!(:perm)   { create(:trailer_access_permission, trailer: trailer, logistician: auth.logistician, sensor_access: false) }
      let(:params)  { { id: trailer.id, _jsonapi: { data: data } } }

      before do
        patch :update, params: params
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid setting ID' do
      let(:params) { { id: -1, _jsonapi: { data: data.merge(id: -1) } } }

      before do
        patch :update, params: params
      end

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid params' do
      let(:params) {
        {
          id: setting.id,
          _jsonapi: {
            data: {
              type: 'trailer_sensor_setting',
              id: setting.id.to_s,
              attributes: {
                alarm_primary_value: 0,
                alarm_secondary_value: -10
              }
            }
          }
        }
      }

      before do
        patch :update, params: params
      end

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'for unauthorized setting' do
      let(:trailer) { create(:trailer) }

      let(:params) {
        {
          id: setting.id,
          _jsonapi: {
            data: data
          }
        }
      }

      before do
        patch :update, params: params
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'without specific access permission' do
      let(:trailer) { create(:trailer) }
      let!(:perm)   { create(:trailer_access_permission, trailer: trailer, logistician: auth.logistician, sensor_access: false) }

      let(:params) {
        {
          id: setting.id,
          _jsonapi: {
            data: data
          }
        }
      }

      before do
        patch :update, params: params
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
