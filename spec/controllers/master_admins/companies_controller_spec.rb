require 'rails_helper'

RSpec.describe MasterAdmins::CompaniesController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:auth] }
  let(:auth) { create(:auth, master_admin: master_admin) }
  let(:master_admin) { create(:master_admin) }

  describe 'GET #new' do
    it 'is successful' do
      sign_in auth
      get :new
      expect(response).to be_successful
    end

    it 'renders correct template' do
      sign_in auth
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'when valid params are passed' do
      let(:params) { { company: { name: 'test_company', street: 'test_street', postal_code: '123-23', nip: '1234567891', city: 'test_city', email: 'test_email@safeway.com' } } }

      it 'redirects to companies index' do
        sign_in auth
        post :create, params: params
        expect(response).to redirect_to admin_companies_path
      end

      it 'redirects with a notice' do
        sign_in auth
        post :create, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when invalid params are passed' do
      let(:params) { { company: { name: '', street: '', postal_code: '', nip: '', city: '', email: '' } } }

      it 'renders new template' do
        sign_in auth
        post :create, params: params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    let(:company) { create(:company) }
    let(:params) { { id: company.id } }

    it 'is successful' do
      sign_in auth
      get :edit, params: params
      expect(response).to be_successful
    end

    it 'renders correct template' do
      sign_in auth
      get :edit, params: params
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'when valid params are passed' do
      let(:company) { create(:company) }
      let(:params) { { id: company.id, company: company.attributes.merge('name' => 'updatedCompanyName') } }

      it 'redirects to companies index' do
        sign_in auth
        expect(patch(:update, params: params)).to redirect_to admin_companies_path
      end

      it 'redirects with a notice' do
        sign_in auth
        patch :update, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when invalid params are passed' do
      let(:company) { create(:company) }
      let(:params) { { id: company.id, company: company.attributes.merge('email' => 'wrongemail') } }

      it 'renders edit template' do
        sign_in auth
        patch :update, params: params
        expect(response).to render_template(:edit)
      end
    end

    context 'when company is not found' do
      let(:company) { create(:company) }
      let(:params) { { id: -5, company: company.attributes } }

      it 'redirects to companies index' do
        sign_in auth
        patch :update, params: params
        expect(response).to redirect_to admin_companies_path
      end

      it 'redirects with an alert' do
        sign_in auth
        patch :update, params: params
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

    it 'renders correct tempalate' do
      sign_in auth
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'DELETE #destroy' do
    context 'when company exists' do
      let(:company) { create(:company) }
      let(:params) { { id: company.id } }

      it 'redirects to companies index' do
        sign_in auth
        delete :destroy, params: params
        expect(response).to redirect_to admin_companies_path
      end

      it 'redirects with a notice' do
        sign_in auth
        delete :destroy, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when company does not exist' do
      let(:params) { { id: -5 } }

      it 'redirects to company index' do
        sign_in auth
        delete :destroy, params: params
        expect(response).to redirect_to admin_companies_path
      end

      it 'redirects with an alert' do
        sign_in auth
        delete :destroy, params: params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #logisticians' do
    before { sign_in auth }
    let(:company) { create(:company) }

    it 'is successful' do
      get :logisticians, params: { id: company.id }
      expect(response).to be_successful
    end

    it 'renders proper template' do
      get :logisticians, params: { id: company.id }
      expect(response).to render_template :logisticians
    end
  end
end
