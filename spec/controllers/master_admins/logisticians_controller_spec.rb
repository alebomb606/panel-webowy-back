require 'rails_helper'

RSpec.describe MasterAdmins::LogisticiansController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:auth] }
  let(:auth) { create(:auth, master_admin: master_admin) }
  let(:master_admin) { create(:master_admin) }

  describe 'GET #show' do
    before { sign_in auth }

    let(:logistician) { create(:logistician, :with_person) }

    it 'is successful' do
      get :show, params: { id: logistician.id }
      expect(response).to be_successful
    end

    it 'renders correct template' do
      get :show, params: { id: logistician.id }
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH #unassign_trailer' do
    before { sign_in auth }

    context 'when valid params are passed' do
      let(:trailer) { create(:trailer) }
      let(:logistician) { create(:logistician, trailers: [trailer]) }

      it 'redirects to logistician\'s show view' do
        patch :unassign_trailer, params: { id: logistician.id, trailer_id: trailer.id }
        expect(response).to redirect_to admin_logistician_path(logistician.id)
      end

      it 'redirects with a notice' do
        patch :unassign_trailer, params: { id: logistician.id, trailer_id: trailer.id }
        expect(flash[:notice]).to be_present
      end
    end

    context 'when trailer is not found' do
      let(:logistician) { create(:logistician) }

      it 'renders show template' do
        patch :unassign_trailer, params: { id: logistician.id, trailer_id: -5 }
        expect(response).to redirect_to(admin_logisticians_path)
        expect(flash[:alert]).to be_present
      end
    end

    context 'when logistician is not found' do
      let(:trailer) { create(:trailer) }

      it 'redirects to logistician\'s index' do
        patch :unassign_trailer, params: { id: -5, trailer_id: trailer.id }
        expect(response).to redirect_to admin_logisticians_path
      end

      it 'redirects with a notice' do
        patch :unassign_trailer, params: { id: -5, trailer_id: trailer.id }
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #index' do
    it 'is successful' do
      sign_in auth
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    before { sign_in auth }

    let(:logistician) { create(:logistician) }

    it 'is successful' do
      get :edit, params: { id: logistician.id }
      expect(response).to be_successful
    end

    it 'renders correct template' do
      get :edit, params: { id: logistician.id }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    before { sign_in auth }

    let(:logistician) { create(:logistician, :with_auth) }
    let!(:person) { create(:person, :with_avatar, personifiable: logistician) }

    context 'when valid params are passed' do
      let(:params) { { id: logistician.id, logistician: { person_attributes: logistician.person.attributes } } }

      it 'redirects to logisticians index' do
        expect(patch(:update, params: params)).to redirect_to admin_logisticians_path
      end

      it 'redirects with a notice' do
        patch :update, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when invalid params are passed' do
      let(:params) { { id: logistician.id, logistician: { person_attributes: logistician.person.attributes.symbolize_keys.merge(first_name: '') } } }

      it 'renders edit template' do
        patch :update, params: params
        expect(response).to render_template(:edit)
      end
    end

    context 'when logistician does not exist' do
      before { sign_in auth }

      let(:params) { { id: -5, logistician: { person_attributes: logistician.person.attributes } } }

      it 'redirect to logisticians index' do
        patch :update, params: params
        expect(response).to redirect_to admin_logisticians_path
      end

      it 'redirects with an alert' do
        patch :update, params: params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #new' do
    before { sign_in auth }

    it 'is successful' do
      get :new
      expect(response).to be_successful
    end

    it 'renders correct template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    before { sign_in auth }

    let(:company) { create(:company) }

    context 'when valid params are passed' do
      let(:params) { { logistician: { person_attributes: attributes_for(:person).merge(company_id: company.id) } } }

      it 'redirects to new logistician path' do
        expect(post(:create, params: params)).to redirect_to new_admin_logistician_path
      end

      it 'redirects with a notice' do
        post :create, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when invalid ID passed' do
      let(:params) { { logistician: { person_attributes: attributes_for(:person, company_id: -5) } } }

      it 'redirects to admin_logisticians_path' do
        post :create, params: params
        expect(response).to redirect_to(admin_logisticians_path)
      end
    end

    context 'when invalid params are passed' do
      let(:params) { { logistician: { person_attributes: attributes_for(:person, email: '', company_id: company.id) } } }

      it 'renders new template' do
        post :create, params: params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in auth }

    context 'when logistician exists' do
      let(:logistician) { create(:logistician) }
      let(:params) { { id: logistician.id } }

      it 'redirects to logisticians index' do
        delete :destroy, params: params
        expect(response).to redirect_to admin_logisticians_path
      end

      it 'redirects with a notice' do
        delete :destroy, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when logistician does not exist' do
      let(:params) { { id: -5 } }

      it 'redirects to logisticians index' do
        delete :destroy, params: params
        expect(response).to redirect_to admin_logisticians_path
      end

      it 'redirects with an alert' do
        delete :destroy, params: params
        expect(flash[:alert]).to be_present
      end
    end
  end
end
