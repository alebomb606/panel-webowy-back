require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before { @request.env["devise.mapping"] = Devise.mappings[:auth] }

  describe 'POST #create' do
    context 'when master admin tries to log in' do
      let(:master_admin) { create(:master_admin) }
      let(:auth) { create(:auth, master_admin: master_admin) }
      let(:params) { { auth: auth.attributes.merge(password: 'password1234') } }

      it 'redirects to root page' do
        post :create, params: params
        expect(response).to redirect_to authenticated_root_path
      end
    end

    context 'when no params are passed in' do
      let(:params) { { auth: { email: '', password: '' } } }

      it 'redirects to new session' do
        post :create, params: params
        expect(response).to redirect_to new_auth_session_path
      end
    end

    context 'when empty hash is sent' do
      let(:params) { { auth: {} } }

      it 'redirects to new session' do
        post :create, params: params
        expect(response).to redirect_to new_auth_session_path
      end
    end

    context 'when logistician tries to log in' do
      let(:logistician) { create(:logistician) }
      let(:auth) { create(:auth, logistician: logistician) }
      let(:params) { { auth: auth.attributes.merge(password: 'password1234') } }

      it 'redirects to new session' do
        post :create, params: params
        expect(response).to redirect_to new_auth_session_path
      end
    end
  end
end
