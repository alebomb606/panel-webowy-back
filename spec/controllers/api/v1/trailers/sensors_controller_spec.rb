require 'rails_helper'

RSpec.describe Api::V1::Trailers::SensorsController do
  let!(:auth) { create(:auth, :with_logistician) }

  before do
    set_jsonapi_headers
    set_auth_headers(auth)
  end

  let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }

  describe 'GET #show' do
    let(:sensor)   { create(:trailer_sensor, trailer: trailer) }

    context 'with valid sensor ID' do
      let!(:setting) { create(:trailer_sensor_setting, sensor: sensor) }
      let!(:reading) { create(:trailer_sensor_reading, sensor: sensor) }
      let!(:event)   { create(:trailer_event, sensor_reading: reading, trailer: trailer) }

      before do
        get :show, params: { id: sensor.id }
      end

      it 'returns data' do
        expect(parsed_response_body[:data]).to include_json(
          id: sensor.id.to_s,
          type: 'trailer_sensor',
          attributes: {
            status: sensor.status,
            value_percentage: sensor.value_percentage,
            value: sensor.value,
            kind: sensor.kind
          },
          relationships: {
            setting: {
              data: {
                id: setting.id.to_s,
                type: 'trailer_sensor_setting'
              }
            }
          }
        )
      end
    end

    context 'with invalid sensor ID' do
      before do
        get :show, params: { id: -1 }
      end

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without permission' do
      let(:trailer)  { create(:trailer) }

      before do
        get :show, params: { id: sensor.id }
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'without necessary permission' do
      let(:trailer)     { create(:trailer) }
      let!(:permission) { create(:trailer_access_permission, sensor_access: false, trailer: trailer, logistician: auth.logistician) }

      before do
        get :show, params: { id: sensor.id }
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET #index' do
    context 'with valid trailer ID' do
      let!(:sensors) { create_list(:trailer_sensor, 3, trailer: trailer, status: :ok) }

      before do
        sensors.each do |sensor|
          create_list(:trailer_sensor_reading, 3, sensor: sensor)
        end

        get :index, params: { trailer_id: trailer.id }
      end

      let(:data) {
        sensors.map do |sensor|
          {
            id: sensor.id.to_s,
            type: 'trailer_sensor',
            attributes: {
              status: sensor.status,
              value: sensor.value,
              value_percentage: sensor.value_percentage,
              kind: sensor.kind,
              average_value: sensor.readings.since_24h.average(:value).round(2).to_f,
              latest_read_at: sensor.readings.by_newest.first.read_at.iso8601
            }
          }
        end
      }

      it 'returns data' do
        expect(parsed_response_body[:data]).to include_json(data)
      end
    end

    context 'with invalid trailer ID' do
      before do
        get :index, params: { trailer_id: -1 }
      end

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns errors' do
        expect(parsed_response_body[:errors].first).to include_json(
          status: '404',
          detail: I18n.t('errors.not_found', resource: 'Trailer')
        )
      end
    end

    context 'with invalid params' do
      before do
        get :index, params: { trailer_id: 'ABC' }
      end

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors' do
        expect(parsed_response_body[:errors]).to include_json(
          [
            detail: I18n.t('errors.int?'),
            title: 'Trailer'
          ]
        )
      end
    end

    context 'without necessary permission' do
      let(:trailer)     { create(:trailer) }
      let!(:permission) { create(:trailer_access_permission, sensor_access: false, trailer: trailer, logistician: auth.logistician) }

      before do
        get :index, params: { trailer_id: trailer.id }
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
