require 'rails_helper'

RSpec.describe Overrides::SessionsController, type: :controller do
  before { @request.env["devise.mapping"] = Devise.mappings[:auth] }

  describe 'POST #create' do
    before do
      set_jsonapi_headers
      post :create, params: params
    end

    context 'when master admin tries to log in' do
      let(:master_admin) { create(:master_admin) }
      let(:auth) { create(:auth, master_admin: master_admin) }
      let(:params) { { email: auth.email, password: 'password1234' } }

      it 'returns 200 OK' do
        expect(response.status).to eq(200)
      end
    end

    context 'when empty params are passed' do
      let(:params) { { email: '', password: '' } }

      it 'returns 401 Unauthorized' do
        expect(response.status).to eq(401)
      end
    end

    context 'when empty hash is sent' do
      let(:params) { {} }

      it 'returns 401 Unauthorized' do
        expect(response.status).to eq(401)
      end
    end

    context 'when logistician tries to log in' do
      let(:logistician) { create(:logistician, trailers: create_list(:trailer, 2)) }
      let(:auth) { create(:auth, logistician: logistician) }
      let(:params) { { email: auth.email, password: 'password1234' } }

      it 'returns 200 OK' do
        expect(response.status).to eq(200)
      end

      it 'returns logistician data in response' do
        expect(parsed_response_body[:data]).to include_json(
          id: auth.id.to_s,
          type: 'auth'
        )
        expect(parsed_response_body[:included]).to include_json(
          [
            id: logistician.id.to_s,
            type: 'logistician'
          ],
          [
            id: logistician.trailer_access_permissions.first.id.to_s,
            type: 'trailer_access_permission'
          ],
          [
            id: logistician.trailer_access_permissions.second.id.to_s,
            type: 'trailer_access_permission'
          ]
        )
      end
    end
  end
end
