require 'rails_helper'

RSpec.describe MasterAdmins::TrailerCamerasController, type: :controller do
  let(:auth) { create(:auth, master_admin: master_admin) }
  let(:master_admin) { create(:master_admin) }
  before { sign_in auth }

  describe 'PATCH #disable' do
    context 'when transaction is successful' do
      let(:trailer) { create(:trailer, :with_cameras, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:params) { { camera_id: trailer.cameras.last.id } }

      it 'redirects to cameras show path' do
        patch :disable, params: params
        expect(response).to redirect_to admin_trailer_cameras_path(trailer.id)
      end

      it 'redirects with a notice' do
        patch :disable, params: params
        expect(flash[:notice]).to be_present
      end

      it 'sets correct status' do
        patch :disable, params: params
        expect(trailer.cameras.last.installed_at).to eq(nil)
      end
    end

    context 'when camera is not found' do
      let(:trailer) { create(:trailer, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:params) { { camera_id: -1 } }

      it 'redirects to trailers index' do
        patch :disable, params: params
        expect(response).to redirect_to admin_trailers_path
      end

      it 'redirects with an alert' do
        patch :disable, params: params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'PATCH #enable' do
    context 'when transaction is successful' do
      let(:trailer) { create(:trailer, :with_cameras, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:params) { { camera_id: trailer.cameras.last.id } }

      it 'redirects to cameras show path' do
        patch :enable, params: params
        expect(response).to redirect_to admin_trailer_cameras_path(trailer.id)
      end

      it 'redirects with a notice' do
        patch :enable, params: params
        expect(flash[:notice]).to be_present
      end

      it 'sets correct status' do
        patch :enable, params: params
        expect(trailer.cameras.last.installed_at).not_to be_nil
      end
    end

    context 'when camera is not found' do
      let(:trailer) { create(:trailer, company: logistician.person.company) }
      let(:logistician) { create(:logistician, :with_person) }
      let(:params) { { camera_id: -1 } }

      it 'redirects to trailers index' do
        patch :enable, params: params
        expect(response).to redirect_to admin_trailers_path
      end

      it 'redirects with an alert' do
        patch :enable, params: params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #index' do
    let(:trailer) { create(:trailer) }

    it 'is successful' do
      get :index, params: { trailer_id: trailer.id }
      expect(response).to render_template :index
    end
  end
end
