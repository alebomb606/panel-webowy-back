require 'rails_helper'

include ActionController::RespondWith

RSpec.describe Api::BaseController do
  let(:auth) { create(:auth) }

  controller do
    def index; end
    def create; end
    def update; end
  end

  describe 'GET #index' do
    context 'without auth headers' do
      before do
        get :index, format: :json
      end

      it 'returns 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid media type headers' do
      before do
        set_auth_headers(auth)
      end

      context 'with invalid accept header' do
        before do
          request.headers['Content-Type'] = 'application/vnd.api+json'
          request.headers['Accept'] = 'application/json'
          get :index
        end

        it 'returns 406' do
          expect(response).to have_http_status(:not_acceptable)
        end
      end

      context 'with valid accept header' do
        before do
          request.headers['Content-Type'] = 'application/vnd.api+json'
          request.headers['Accept'] = 'application/vnd.api+json'
          get :index
        end

        it 'returns 402' do
          expect(response).to have_http_status(:no_content)
        end
      end
    end
  end

  describe 'POST #create' do
    before do
      set_auth_headers(auth)
    end

    context 'with invalid headers' do
      before do
        request.headers['Content-Type'] = 'application/json'
        post :create
      end

      it 'returns 415' do
        expect(response).to have_http_status(:unsupported_media_type)
      end
    end

    context 'with valid headers' do
      before do
        request.headers['Accept'] = 'application/vnd.api+json'
        request.headers['Content-Type'] = 'application/vnd.api+json'
        post :create
      end

      it 'returns 204' do
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'PUT #update' do
    before do
      set_auth_headers(auth)
    end

    context 'with invalid headers' do
      before do
        request.headers['Content-Type'] = 'application/json'
        put :update, params: { id: 1234 }
      end

      it 'returns 415' do
        expect(response).to have_http_status(:unsupported_media_type)
      end
    end

    context 'with valid headers' do
      before do
        request.headers['Content-Type'] = 'application/vnd.api+json'
        request.headers['Accept'] = 'application/vnd.api+json'
        post :create
      end

      it 'returns 204' do
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
