require 'rails_helper'

RSpec.describe MasterAdmins::AccessPermissionsController, type: :controller do
  let(:auth) { create(:auth, master_admin: master_admin) }
  let(:master_admin) { create(:master_admin) }
  before { sign_in auth }

  describe 'GET #new' do
    let(:logistician) { create(:logistician, :with_person) }
    let(:trailer) { create(:trailer, company: logistician.person.company) }

    it 'is successful' do
      get :new, params: { logistician_id: logistician.id, trailer_id: trailer.id }
      expect(response).to be_successful
    end

    it 'renders correct template' do
      get :new, params: { logistician_id: logistician.id, trailer_id: trailer.id }
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    let(:trailer) { create(:trailer, company: logistician.person.company) }
    let(:logistician) { create(:logistician, :with_person) }
    let(:access_permissions) { create(:trailer_access_permission, logistician_id: logistician.id, trailer_id: trailer.id) }

    it 'is successful' do
      get :edit, params: { id: access_permissions.id, logistician_id: logistician.id }
      expect(response).to be_successful
    end

    it 'renders correct template' do
      get :edit, params: { id: access_permissions.id, logistician_id: logistician.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'when transaction is successful' do
      let(:trailer) { create(:trailer, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:params) { { trailer_id: trailer.id, trailer_access_permission: attributes_for(:trailer_access_permission, logistician_id: logistician.id, trailer_id: -5) } }

      it 'redirects to logisticians show path' do
        post :create, params: params
        expect(response).to redirect_to admin_logistician_path(logistician.id)
      end

      it 'redirects with a notice' do
        post :create, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when trailer is not found' do
      let(:logistician) { create(:logistician, :with_person) }
      let(:params) { { trailer_id: -5, trailer_access_permission: { logistician_id: logistician.id, trailer_id: -5 } } }

      it 'redirects to logisticians show path' do
        post :create, params: params
        expect(response).to redirect_to admin_logistician_path(logistician.id)
      end

      it 'redirects with an alert' do
        post :create, params: params
        expect(flash[:alert]).to be_present
      end
    end

    context 'when logistician is not found' do
      let(:trailer) { create(:trailer) }
      let(:params) { { trailer_id: trailer.id, trailer_access_permission: { logistician_id: -5, trailer_id: trailer.id } } }

      it 'redirects to logisticians index' do
        post :create, params: params
        expect(response).to redirect_to admin_logisticians_path
      end

      it 'redirects with an alert' do
        post :create, params: params
        expect(flash[:alert]).to be_present
      end
    end

    context 'when transaction fails' do
      let(:trailer) { create(:trailer, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:params) { { trailer_id: trailer.id, logistician_id: logistician.id, trailer_access_permission: attributes_for(:trailer_access_permission, sensor_access: 'wrong_value', logistician_id: logistician.id, trailer_id: trailer.id) } }

      it 'renders new template' do
        post :create, params: params
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    context 'when transaction is successful' do
      let(:trailer) { create(:trailer, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:access_permissions) { create(:trailer_access_permission, logistician_id: logistician.id, trailer_id: trailer.id) }
      let(:params) { { id: access_permissions.id, trailer_access_permission: access_permissions.attributes.symbolize_keys } }

      it 'redirects to logistician show path' do
        post :update, params: params
        expect(response).to redirect_to admin_logistician_path(logistician.id)
      end

      it 'redirects with a notice' do
        post :update, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when logistician is not found' do
      let(:trailer) { create(:trailer, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:access_permissions) { create(:trailer_access_permission, logistician_id: logistician.id, trailer_id: trailer.id) }
      let(:params) { { id: access_permissions.id, trailer_access_permission: access_permissions.attributes.symbolize_keys.merge(logistician_id: -5) } }

      it 'redirects to logisticians index' do
        post :update, params: params
        expect(response).to redirect_to admin_logisticians_path
      end

      it 'redirects with an alert' do
        post :update, params: params
        expect(flash[:alert]).to be_present
      end
    end

    context 'when permission is not found' do
      let(:trailer) { create(:trailer, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:access_permissions) { create(:trailer_access_permission, logistician_id: logistician.id, trailer_id: trailer.id) }
      let(:params) { { id: -5, trailer_access_permission: access_permissions.attributes.symbolize_keys } }

      it 'redirects to logistician show path' do
        post :update, params: params
        expect(response).to redirect_to admin_logistician_path(logistician.id)
      end

      it 'redirects with an alert' do
        post :update, params: params
        expect(flash[:alert]).to be_present
      end
    end

    context 'when transaction fails' do
      let(:trailer) { create(:trailer, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:access_permissions) { create(:trailer_access_permission, logistician_id: logistician.id, trailer_id: trailer.id) }
      let(:params) { { id: access_permissions.id, trailer_access_permission: access_permissions.attributes.symbolize_keys.merge(sensor_access: 'wrong_value') } }

      it 'renders new template' do
        post :update, params: params
        expect(response).to render_template :edit
      end
    end
  end

  describe 'GET #index' do
    let(:trailer) { create(:trailer) }

    it 'is successful' do
      get :index, params: { trailer_id: trailer.id }
      expect(response).to render_template :index
    end

    it 'renders correct template' do
      get :index, params: { trailer_id: trailer.id }
      expect(response).to render_template :index
    end
  end
end
