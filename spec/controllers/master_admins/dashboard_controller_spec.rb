require 'rails_helper'

RSpec.describe MasterAdmins::DashboardController, type: :controller do
  describe 'GET #index' do
    before { @request.env['devise.mapping'] = Devise.mappings[:auth] }

    let(:auth) { create(:auth, master_admin: master_admin) }
    let(:master_admin) { create(:master_admin) }

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
end
