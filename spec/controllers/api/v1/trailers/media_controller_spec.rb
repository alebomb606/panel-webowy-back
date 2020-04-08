require 'rails_helper'

RSpec.describe Api::V1::Trailers::MediaController do
  let!(:auth)       { create(:auth, :with_logistician) }
  let(:logistician) { auth.logistician }
  let(:trailer)     { create(:trailer, :with_permission, permission_logistician: logistician) }

  before do
    set_jsonapi_headers
    set_auth_headers(auth)
  end

  describe 'GET #index' do
    before do
      get :index, params: params
    end

    context 'with invalid trailer ID' do
      let(:params) { { trailer_id: -1 } }

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns errors' do
        expect(parsed_response_body[:errors].first).to include_json(
          status: '404',
          detail: I18n.t('errors.not_found', resource: 'Trailer')
        )
      end
    end

    context 'with invalid params' do
      let(:params) { { trailer_id: trailer.id, filter: { date_from: '', date_to: '', cameras: "wrong_camera", statuses: "wrong_status", kinds: "wring_kind" } } }

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors' do
        expect(parsed_response_body).to include_json(
          errors: [
            {
              title: 'Date from',
              detail: I18n.t('errors.filled?')
            },
            {
              title: 'Date to',
              detail: I18n.t('errors.filled?')
            },
            {
              title: 'Cameras.0',
              detail: I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.cameras.keys.join(', '))
            },
            {
              title: 'Kinds.0',
              detail: I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.kinds.keys.join(', '))
            },
            {
              title: 'Statuses.0',
              detail: I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.statuses.keys.join(', '))
            }
          ]
        )
      end
    end

    context 'with one invalid param' do
      let!(:params) {
        {
          trailer_id: trailer.id,
          filter: {
            cameras: "wrong_camera",
            statuses: ::DeviceMediaFile.statuses.keys.join(','),
          }
        }
      }
      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors' do
        expect(parsed_response_body).to include_json(
          errors: [
            {
              title: 'Cameras.0',
              detail: I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.cameras.keys.join(', '))
            }
          ]
        )
      end
    end

    context 'with one invalid camera' do
      let(:params) {
        {
          trailer_id: trailer.id,
          filter: {
            cameras: "non-existing, #{::DeviceMediaFile.cameras.keys.first}"
          }
        }
      }

      it 'returns errors' do
        expect(parsed_response_body).to include_json(
          errors: [
            {
              title: "Cameras.0",
              detail: I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.cameras.keys.join(', '))
            }
          ]
        )
      end
    end

    context 'with one invalid kind' do
      let(:params) {
        {
          trailer_id: trailer.id,
          filter: {
            kinds: "non-existing, #{::DeviceMediaFile.kinds.keys.first}"
          }
        }
      }

      it 'returns errors' do
        expect(parsed_response_body).to include_json(
          errors: [
            {
              title: "Kinds.0",
              detail: I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.kinds.keys.join(', '))
            }
          ]
        )
      end
    end

    context 'with one invalid status' do
      let(:params) {
        {
          trailer_id: trailer.id,
          filter: {
            statuses: "non-existing, #{::DeviceMediaFile.statuses.keys.first}"
          }
        }
      }

      it 'returns errors' do
        expect(parsed_response_body).to include_json(
          errors: [
            {
              title: "Statuses.0",
              detail: I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.statuses.keys.join(', '))
            }
          ]
        )
      end
    end

    context 'with valid params' do
      let(:params) {
        {
          trailer_id: trailer.id,
          page: { number: 1, size: 2 },
          filter: {
            date_from: 2.years.ago.iso8601,
            date_to: Time.current.iso8601,
            kinds: "photo",
            statuses: "completed",
            cameras: "exterior, interior"
          }
        }
      }

      context 'with permissions' do
        let!(:requested_media_file)  { create(:device_media_file, trailer: trailer, kind: :photo, status: :request, camera: :exterior, requested_time: 2.minutes.ago, logistician: logistician) }
        let!(:first_media_file)  { create(:device_media_file, trailer: trailer, kind: :photo, status: :completed, camera: :exterior, requested_time: 10.minutes.ago, logistician: logistician) }
        let!(:second_media_file) { create(:device_media_file, trailer: trailer, kind: :photo, status: :completed, camera: :interior, requested_time: 15.minutes.ago, logistician: logistician) }
        let!(:third_media_file) { create(:device_media_file, trailer: trailer, kind: :video,  status: :completed, camera: :interior, requested_time: 20.minutes.ago, logistician: logistician) }
        let!(:fourth_media_file) { create(:device_media_file, trailer: trailer, kind: :video, status: :completed, camera: :exterior, requested_time: 25.minutes.ago, logistician: logistician) }
        let!(:other_files) { create_list(:device_media_file, 3, trailer: trailer, status: :completed, kind: :photo, camera: :interior, requested_time: 2.days.ago, logistician: logistician) }

        let(:links) { parsed_response_body[:links] }

        before do
          get :index, params: params
        end

        it 'returns success status' do
          expect(response).to have_http_status(:success)
        end

        it 'returns pagination info' do
          expect(links[:prev]).to be_nil
          expect(links[:next]).not_to be_nil
          expect(links[:first]).not_to be_nil
          expect(links[:last]).not_to be_nil
        end

        it 'returns paginated data' do
          expect(parsed_response_body[:data].count).to eq(2)
          expect(parsed_response_body[:data]).to include_json(
            [
              {
                id: first_media_file.id.to_s,
                type: 'trailer_media',
                attributes: {
                  requested_time: first_media_file.requested_time.iso8601
                }
              },
              {
                id: second_media_file.id.to_s,
                type: 'trailer_media',
                attributes: {
                  requested_time: second_media_file.requested_time.iso8601,
                }
              }
            ]
          )
        end

        context 'without specific permission' do
          let(:trailer) { create(:trailer) }
          let!(:perm)   { create(:trailer_access_permission, logistician: logistician, trailer: trailer, monitoring_access: false) }

          before do
            get :index, params: params
          end

          it 'returns 403' do
            expect(response).to have_http_status(:forbidden)
          end
        end
      end
    end
  end

  describe '#request' do
    before do
      post :request_media, params: params
    end

    context 'with valid params' do
      let(:params) {
        {
          trailer_id: trailer.id,
          _jsonapi: {
            data: {
              type: 'trailer',
              id: trailer.id.to_s,
              attributes: {
                requested_time: Faker::Time.between(1.day.ago, Date.today, :day).iso8601,
                kind: 'photo',
                camera: 'left_top'
              }
            }
          }
        }
      }

      it 'returns 201 Created and returns a record' do
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      let(:params) {
        {
          trailer_id: trailer.id,
          _jsonapi: {
            data: {
              type: 'trailer',
              id: trailer.id.to_s,
              attributes: {
                requested_time: '',
                kind: nil,
                camera: 'xyzabc'
              }
            }
          }
        }
      }

      it 'returns 422 and a list of errors' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response_body).to include_json(
          errors: [
            {
              title: 'Requested time',
              detail: I18n.t('errors.filled?')
            },
            {
              title: 'Kind',
              detail: I18n.t('errors.filled?')
            },
            {
              title: 'Camera',
              detail: I18n.t('errors.included_in?.arg.default', list: ::DeviceMediaFile.cameras.keys.join(', '))
            }
          ]
        )
      end
    end

    context 'with no trailer available' do
      let(:params) {
        {
          trailer_id: -1,
          _jsonapi: {
            data: {
              type: 'trailer',
              id: '-1',
              attributes: {
                requested_time: Faker::Time.between(1.day.ago, Date.today, :day).iso8601,
                kind: 'photo',
                camera: 'left_top'
              }
            }
          }
        }
      }

      it 'returns 404 Not Found' do
        expect(response).to have_http_status(:not_found)
        expect(parsed_response_body[:errors].first).to include_json(
          status: '404',
          detail: I18n.t('errors.not_found', resource: 'Trailer')
        )
      end
    end

    context 'with trailer belonging to another logistician' do
      let(:trailer) { create(:trailer) }

      let(:params) {
        {
          trailer_id: trailer.id,
          _jsonapi: {
            data: {
              type: 'trailer',
              id: trailer.id.to_s,
              attributes: {
                requested_time: Faker::Time.between(1.day.ago, Date.today, :day).iso8601,
                kind: 'photo',
                camera: 'left_top'
              }
            }
          }
        }
      }

      it 'returns 404 Not Found' do
        expect(response).to have_http_status(:not_found)
        expect(parsed_response_body[:errors].first).to include_json(
          status: '404',
          detail: I18n.t('errors.not_found', resource: 'Trailer')
        )
      end
    end

    context 'without specific permission' do
      let(:trailer) { create(:trailer) }
      let!(:perm)   { create(:trailer_access_permission, logistician: logistician, trailer: trailer, photo_download: false) }

      let(:params) {
        {
          trailer_id: trailer.id,
          _jsonapi: {
            data: {
              type: 'trailer',
              id: trailer.id.to_s,
              attributes: {
                requested_time: Faker::Time.between(1.day.ago, Date.today, :day).iso8601,
                kind: 'photo',
                camera: 'left_top'
              }
            }
          }
        }
      }

      before do
        post :request_media, params: params
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
