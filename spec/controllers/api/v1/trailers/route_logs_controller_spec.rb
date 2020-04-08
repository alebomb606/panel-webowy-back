require 'rails_helper'

RSpec.describe Api::V1::Trailers::RouteLogsController do
  let!(:auth) { create(:auth, :with_logistician) }

  before do
    set_jsonapi_headers
    set_auth_headers(auth)
  end

  describe 'GET #index' do
    context 'when valid params are passed' do
      let(:trailer)    { create(:trailer, :with_permission, permission_logistician: auth.logistician) }
      let!(:route_log) { create(:route_log, trailer_id: trailer.id, longitude: 13.3, latitude: 10.1, sent_at: 1.day.ago, speed: 22.2) }

      context 'with filter param passed' do
        let(:params)       { { trailer_id: trailer.id, filter: { date_from: 30.minutes.ago.iso8601 } } }
        let!(:route_log_2) { create(:route_log, trailer_id: trailer.id, sent_at: 20.minutes.ago) }

        before do
          get :index, params: params
        end

        it 'returns status 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns proper payload' do
          expect(parsed_response_body[:data]).to include_json([{ id: route_log_2.id.to_s }])
        end
      end

      context 'on the first request' do
        before do
          get :index, params: { trailer_id: trailer.id }
        end

        it 'returns status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns proper payload' do
          expect(parsed_response_body).to eq(data: [
            id: route_log.id.to_s,
            type: 'route_log',
            attributes: {
              longitude: '13.3',
              latitude: '10.1',
              location_name: route_log.location_name,
              sent_at: route_log.sent_at.iso8601,
              speed: '22.2'
            }
          ])
        end
      end

      context 'on a subsequent request' do
        before do
          get :index, params: { trailer_id: trailer.id }
          @etag = response.headers['ETag']
          @last_modified = response.headers['Last-Modified']
        end

        it 'returns status 200' do
          expect(response).to have_http_status :ok
        end

        context 'when not stale' do
          before do
            request.headers.merge!(
              'HTTP_IF_NONE_MATCH' => @etag,
              'HTTP_IF_MODIFIED_SINCE' => @last_modified
            )
            get :index, params: { trailer_id: trailer.id }
          end

          it 'returns status 304' do
            expect(response).to have_http_status :not_modified
          end
        end

        context 'when content has been changed' do
          before do
            route_log.touch
            request.headers.merge!(
              'HTTP_IF_NONE_MATCH' => @etag,
              'HTTP_IF_MODIFIED_SINCE' => @last_modified
            )
            get :index, params: { trailer_id: trailer.id }
          end

          it 'returns status 200' do
            expect(response).to have_http_status :ok
          end
        end
      end
    end

    context 'when trailer is not found' do
      before { get :index, params: { trailer_id: -5 } }

      it 'returns status 404' do
        expect(response).to have_http_status :not_found
      end
    end

    context 'when trailer is archived' do
      let(:trailer) { create(:trailer, :archived) }

      before { get :index, params: { trailer_id: trailer.id } }

      it 'returns status 404' do
        expect(response).to have_http_status :not_found
      end
    end

    context 'when validation fails' do
      before { get :index, params: { trailer_id: 'test_id' } }

      it 'returns status 422' do
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'when has no access permissions' do
      let(:trailer) { create(:trailer) }

      before { get :index, params: { trailer_id: trailer.id } }

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without specific permission' do
      let(:trailer) { create(:trailer) }
      let!(:perm)   { create(:trailer_access_permission, logistician: auth.logistician, trailer: trailer, route_access: false) }

      before { get :index, params: { trailer_id: trailer.id } }

      it 'returns status 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
