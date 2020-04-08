require 'rails_helper'

RSpec.describe Api::V1::TrailersController do
  let!(:auth) { create(:auth, :with_logistician) }

  before do
    set_jsonapi_headers
    set_auth_headers(auth)
  end

  describe '#show' do
    context 'with valid ID' do
      let(:trailer) { create(:trailer, :with_cameras, :with_permission, permission_logistician: auth.logistician) }

      before do
        get :show, params: { id: trailer.id }
      end

      it 'returns trailer data' do
        expect(parsed_response_body[:data]).to include_json(
          id: trailer.id.to_s,
          type: 'trailer',
          attributes: {
            device_serial_number: trailer.device_serial_number,
            registration_number: trailer.registration_number,
            make: trailer.make,
            model: trailer.model,
            description: trailer.description
          }
        )
      end
    end

    context 'with invalid ID' do
      before do
        get :show, params: { id: -1 }
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

    context 'without permissions for specific trailer' do
      let(:trailer) { create(:trailer) }

      before do
        get :show, params: { id: trailer.id }
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
  end

  describe '#index' do
    context 'with valid params' do
      let!(:trailers) { create_list(:trailer, 5, :with_permission, permission_logistician: auth.logistician) }
      let(:trailer_1) { trailers.first }
      let(:trailer_2) { trailers.second }

      before do
        get :index, params: { page: { number: 1, size: 2 } }
      end

      it 'returns paginated data' do
        expect(parsed_response_body[:data].size).to eq(2)
        expect(parsed_response_body[:links][:prev]).to be_nil
        expect(parsed_response_body[:links][:next]).not_to be_nil
        expect(parsed_response_body[:links][:first]).not_to be_nil
        expect(parsed_response_body[:links][:last]).not_to be_nil
      end

      it 'returns trailers data' do
        expect(parsed_response_body[:data]).to include_json(
          [
            {
              id: trailer_1.id.to_s,
              type: 'trailer',
              attributes: {
                device_serial_number: trailer_1.device_serial_number,
                registration_number: trailer_1.registration_number,
                current_position: {}
              },
              relationships: { access_permission: {} }
            },
            {
              id: trailer_2.id.to_s,
              type: 'trailer',
              attributes: {
                device_serial_number: trailer_2.device_serial_number,
                registration_number: trailer_2.registration_number,
                current_position: {}
              },
              relationships: { access_permission: {} }
            }
          ]
        )
      end

      it 'returns included data' do
        expect(parsed_response_body[:included].count).to eq(2)
        expect(parsed_response_body[:included]).to include_json(
          [
            {
              id: trailer_1.access_permissions.first.id.to_s,
              type: 'trailer_access_permission',
              attributes: {}
            },
            {
              id: trailer_2.access_permissions.first.id.to_s,
              type: 'trailer_access_permission',
              attributes: {}
            }
          ]
        )
      end
    end

    context 'when has no permissions for any trailer' do
      let!(:trailers) { create_list(:trailer, 5) }

      before do
        get :index
      end

      it 'returns no data' do
        expect(parsed_response_body[:data]).to be_empty
      end
    end

    context 'without current_position access permission' do
      let!(:trailer) { create(:trailer) }
      let!(:perm)    { create(:trailer_access_permission, trailer: trailer, logistician: auth.logistician, current_position: false) }

      before do
        get :index
      end

      it 'returns data without position' do
        expect(parsed_response_body[:data]).to include_json(
          [
            {
              id: trailer.id.to_s,
              type: 'trailer',
              attributes: { current_position: nil }
            }
          ]
        )
      end
    end

    context 'without route log' do
      let!(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }

      before do
        get :index
      end

      it 'returns data without position' do
        expect(parsed_response_body[:data]).to include_json(
          [
            {
              id: trailer.id.to_s,
              type: 'trailer',
              attributes: { current_position: nil }
            }
          ]
        )
      end
    end
  end

  describe 'PATCH #update_status' do
    context 'with valid params' do
      let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician, status: :alarm_silenced) }
      let(:params)  {
        {
          id: trailer.id,
          _jsonapi: {
            data: {
              id: trailer.id,
              type: 'trailer',
              attributes: {
                status: 'alarm'
              }
            }
          }
        }
      }

      let!(:position) { create(:route_log, trailer: trailer) }

      before do
        patch :update_status, params: params
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns updated trailer data' do
        expect(parsed_response_body[:data]).to include_json(
          id: trailer.id.to_s,
          type: 'trailer',
          attributes: {
            device_serial_number: trailer.device_serial_number,
            registration_number: trailer.registration_number,
            make: trailer.make,
            model: trailer.model,
            description: trailer.description,
            status: 'alarm',
            current_position: {
              latitude: position.latitude.to_s,
              longitude: position.longitude.to_s
            }
          }
        )
      end
    end

    context 'without needed permission' do
      let(:trailer) { create(:trailer, status: :alarm_silenced) }
      let!(:perm)   { create(:trailer_access_permission, trailer: trailer, logistician: auth.logistician, alarm_control: false) }

      let(:params)  {
        {
          id: trailer.id.to_s,
          _jsonapi: {
            data: {
              id: trailer.id,
              type: 'trailer',
              attributes: {
                status: 'alarm'
              }
            }
          }
        }
      }

      before do
        patch :update_status, params: params
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid ID' do
      let(:params)  {
        {
          id: -1,
          _jsonapi: {
            data: {
              id: -1,
              type: 'trailer',
              attributes: {
                status: 'alarm'
              }
            }
          }
        }
      }

      before do
        patch :update_status, params: params
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

    context 'with invalid param' do
      let(:trailer) {
        create(:trailer,
          :with_permission,
          permission_logistician: auth.logistician,
          status: :alarm_silenced
        )
      }
      let(:params)  {
        {
          id: trailer.id,
          _jsonapi: {
            data: {
              id: trailer.id,
              type: 'trailer',
              attributes: {
                status: trailer.status
              }
            }
          }
        }
      }

      before do
        patch :update_status, params: params
      end

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
