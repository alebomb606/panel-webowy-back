require 'rails_helper'

RSpec.describe MasterAdmins::TrailersController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:auth] }
  let(:auth) { create(:auth, master_admin: master_admin) }
  let(:master_admin) { create(:master_admin) }

  describe 'GET #edit' do
    let(:trailer) { create(:trailer) }
    let(:params) { { id: trailer.id } }

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
      let(:trailer) { create(:trailer) }
      let(:params) { { id: trailer.id, trailer: trailer.attributes.symbolize_keys } }

      it 'redirects to trailers index' do
        sign_in auth
        patch :update, params: params
        expect(response).to redirect_to admin_trailers_path
      end

      it 'redirects with a notice' do
        sign_in auth
        patch :update, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when invalid params are passed' do
      let(:trailer) { create(:trailer) }
      let(:params) { { id: trailer.id, trailer: trailer.attributes.symbolize_keys } }

      it 'renders edit template' do
        sign_in auth
        params[:trailer][:model] = ''
        patch :update, params: params
        expect(response).to render_template(:edit)
      end
    end

    context 'when company is not found' do
      let(:trailer) { create(:trailer) }
      let(:params) { { id: trailer.id, trailer: trailer.attributes.merge(company_id: -5).symbolize_keys } }

      it 'redirects to trailers index' do
        sign_in auth
        patch :update, params: params
        expect(response).to redirect_to admin_trailers_path
      end
    end

    context 'when trailer is not found' do
      let(:trailer) { create(:trailer) }
      let(:params) { { id: -5, trailer: trailer.attributes.symbolize_keys } }

      it 'redirects to trailers index' do
        sign_in auth
        patch :update, params: params
        expect(response).to redirect_to admin_trailers_path
      end
    end
  end

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
      let(:company) { create(:company) }
      let(:plan_params) { { plan_attributes: attributes_for(:plan) }}
      let(:params) { { trailer: attributes_for(:trailer, company_id: company.id).merge(plan_params) } }

      it 'redirects to trailers index' do
        sign_in auth
        post :create, params: params
        expect(response).to redirect_to admin_trailers_path
      end

      it 'redirects with a notice' do
        sign_in auth
        post :create, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when invalid params are passed' do
      let(:company) { create(:company) }
      let(:params) { { trailer: attributes_for(:trailer, model: '', company_id: company.id) } }

      it 'renders new template' do
        sign_in auth
        post :create, params: params
        expect(response).to render_template(:new)
      end
    end

    context 'when company does not exist' do
      let(:params) { { trailer: attributes_for(:trailer, company_id: -5) } }

      it 'renders new template' do
        sign_in auth
        post :create, params: params
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #index' do
    it 'is successful' do
      sign_in auth
      get :index
      expect(response).to be_successful
    end

    it 'renders correct template' do
      sign_in auth
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'DELETE #destroy' do
    context 'when trailer exists' do
      let(:trailer) { create(:trailer) }
      let(:params) { { id: trailer.id } }

      it 'redirects to trailers index' do
        sign_in auth
        delete :destroy, params: params
        expect(response).to redirect_to admin_trailers_path
      end

      it 'redirects with a notice' do
        sign_in auth
        delete :destroy, params: params
        expect(flash[:notice]).to be_present
      end
    end

    context 'when trailer does not exist' do
      let(:params) { { id: -5 } }

      it 'redirects to trailers index' do
        sign_in auth
        delete :destroy, params: params
        expect(response).to redirect_to admin_trailers_path
      end

      it 'redirects with an alert' do
        sign_in auth
        delete :destroy, params: params
        expect(flash[:alert]).to be_present
      end
    end
  end
end
