require 'rails_helper'

RSpec.describe Api::V1::Trailers::Sensors::EventsController do
  let!(:auth) { create(:auth, :with_logistician) }

  before do
    set_jsonapi_headers
    set_auth_headers(auth)
  end

  let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }

  describe 'GET #index' do
    let(:sensor)     { create(:trailer_sensor, trailer: trailer) }

    context 'with valid sensor ID' do
      let!(:reading_1) { create(:trailer_sensor_reading, sensor: sensor) }
      let!(:reading_2) { create(:trailer_sensor_reading, sensor: sensor) }
      let!(:reading_3) { create(:trailer_sensor_reading, sensor: sensor) }
      let!(:event_1)   { create(:trailer_event, sensor_reading: reading_1, trailer: trailer, triggered_at: 2.days.ago) }
      let!(:event_2)   { create(:trailer_event, sensor_reading: reading_2, trailer: trailer, triggered_at: 3.days.ago) }
      let!(:event_3)   { create(:trailer_event, sensor_reading: reading_3, trailer: trailer, triggered_at: 4.days.ago) }

      before do
        get :index, params: { sensor_id: sensor.id, page: { size: 2 } }
      end

      it 'returns data' do
        expect(parsed_response_body[:data].count).to eq(2)
        expect(parsed_response_body[:data]).to include_json([
          {
            id: event_1.id.to_s,
            type: 'trailer_event',
            attributes: {
              kind: event_1.kind
            }
          },
          {
            id: event_2.id.to_s,
            type: 'trailer_event',
            attributes: {
              kind: event_2.kind
            }
          }
        ])
      end

      let(:included_data) {
        [
          {
            id: reading_1.id.to_s,
            type: 'trailer_sensor_reading',
            attributes: {
              original_value: reading_1.original_value,
              value: reading_1.value,
              value_percentage: reading_1.value_percentage,
              status: reading_1.status,
              read_at: reading_1.read_at.iso8601
            }
          },
          {
            id: reading_2.id.to_s,
            type: 'trailer_sensor_reading',
            attributes: {
              original_value: reading_2.original_value,
              value: reading_2.value,
              value_percentage: reading_2.value_percentage,
              status: reading_2.status,
              read_at: reading_2.read_at.iso8601
            }
          }
        ]
      }

      it 'returns included data' do
        expect(parsed_response_body[:included].count).to eq(2)
        expect(parsed_response_body[:included]).to include_json(included_data)
      end
    end

    context 'with invalid sensor ID' do
      before do
        get :index, params: { sensor_id: -1 }
      end

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with no access to the sensor' do
      let(:trailer) { create(:trailer) }

      before do
        get :index, params: { sensor_id: sensor.id }
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'without specific permission' do
      let(:trailer)     { create(:trailer) }
      let!(:permission) { create(:trailer_access_permission, sensor_access: false, trailer: trailer, logistician: auth.logistician) }

      before do
        get :index, params: { sensor_id: sensor.id }
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
