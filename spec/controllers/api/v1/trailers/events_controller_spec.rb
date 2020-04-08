require 'rails_helper'

RSpec.describe Api::V1::Trailers::EventsController do
  let!(:auth) { create(:auth, :with_logistician) }

  before do
    set_jsonapi_headers
    set_auth_headers(auth)
  end

  describe 'GET #index' do
    context 'with invalid trailer ID' do
      before do
        get :index, params: { trailer_id: -1 }
      end

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
      let(:trailer) { create(:trailer) }

      before do
        get :index, params: { trailer_id: trailer.id, filter: { date_from: '', date_to: '' } }
      end

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
            }
          ]
        )
      end
    end

    context 'without necessary permission' do
      let(:trailer)     { create(:trailer) }
      let!(:permission) { create(:trailer_access_permission, event_log_access: false, trailer: trailer, logistician: auth.logistician) }

      before do
        get :index, params: { trailer_id: trailer.id }
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with valid params' do
      let(:trailer)       { create(:trailer, :with_permission, permission_logistician: auth.logistician) }
      let!(:first_event)  { create(:trailer_event, trailer: trailer, triggered_at: 10.minutes.ago, kind: :alarm) }
      let!(:second_event) { create(:trailer_event, trailer: trailer, triggered_at: 15.minutes.ago, kind: :alarm) }
      let!(:other_events) { create_list(:trailer_event, 3, trailer: trailer, triggered_at: 2.days.ago, kind: :alarm) }
      let(:params) {
        {
          trailer_id: trailer.id,
          page: { number: 1, size: 2 },
          filter: {
            date_from: 2.years.ago.iso8601,
            date_to: Time.current.iso8601,
            kinds: 'alarm'
          }
        }
      }

      before do
        get :index, params: params
      end

      it 'returns pagination info' do
        expect(parsed_response_body[:links][:prev]).to be_nil
        expect(parsed_response_body[:links][:next]).not_to be_nil
        expect(parsed_response_body[:links][:first]).not_to be_nil
        expect(parsed_response_body[:links][:last]).not_to be_nil
      end

      it 'returns paginated data' do
        expect(parsed_response_body[:data].count).to eq(2)
        expect(parsed_response_body[:data]).to include_json(
          [
            {
              id: first_event.id.to_s,
              type: 'trailer_event',
              attributes: {
                kind: first_event.kind,
                sensor_name: first_event.sensor_name,
                triggered_at: first_event.triggered_at.iso8601,
                uuid: first_event.uuid,
                latitude: first_event.route_log.latitude.to_s,
                longitude: first_event.route_log.longitude.to_s
              }
            },
            {
              id: second_event.id.to_s,
              type: 'trailer_event',
              attributes: {
                kind: second_event.kind,
                sensor_name: second_event.sensor_name,
                triggered_at: second_event.triggered_at.iso8601,
                uuid: second_event.uuid,
                latitude: second_event.route_log.latitude.to_s,
                longitude: second_event.route_log.longitude.to_s
              }
            }
          ]
        )
      end

      it 'returns included data' do
        expect(parsed_response_body[:included].count).to eq(5)
        expect(parsed_response_body[:included]).to match_unordered_json(
          [
            {
              type: 'logistician',
              attributes: {
                first_name: first_event.logistician.person.first_name,
                last_name: first_event.logistician.person.last_name,
              }
            },
            {
              type: 'route_log',
              attributes: {
                latitude: first_event.route_log.latitude.to_s,
                longitude: first_event.route_log.longitude.to_s,
                speed: first_event.route_log.speed.to_s,
                location_name: first_event.route_log.location_name,
                sent_at: first_event.route_log.sent_at.iso8601,
              }
            },
            {
              type: 'trailer',
              attributes: {
                device_serial_number: first_event.trailer.device_serial_number,
                registration_number: first_event.trailer.registration_number,
                device_installed_at: first_event.trailer.device_installed_at.iso8601,
                make: first_event.trailer.make,
                model: first_event.trailer.model,
                description: first_event.trailer.description,
                engine_running: first_event.trailer.engine_running
              }
            },
            {
              type: 'logistician',
              attributes: {
                first_name: second_event.logistician.person.first_name,
                last_name: second_event.logistician.person.last_name,
              }
            },
            {
              type: 'route_log',
              attributes: {
                latitude: second_event.route_log.latitude.to_s,
                longitude: second_event.route_log.longitude.to_s,
                speed: second_event.route_log.speed.to_s,
                location_name: second_event.route_log.location_name,
                sent_at: second_event.route_log.sent_at.iso8601,
              }
            },
          ]
        )
      end

      context 'with interactions' do
        let!(:reaction_event) {
          create(
            :trailer_event,
            trailer: trailer,
            triggered_at: 10.minutes.ago,
            linked_event: second_event,
            kind: :alarm_resolved
          )
        }

        before do
          get :index, params: params
        end

        it 'returns included data' do
          expect(parsed_response_body[:included].count).to eq(7)
          expect(parsed_response_body[:included]).to match_unordered_json(
            [
              {
                type: 'logistician',
                attributes: {
                  first_name: first_event.logistician.person.first_name,
                  last_name: first_event.logistician.person.last_name
                }
              },
              {
                type: 'route_log',
                attributes: {
                  latitude: first_event.route_log.latitude.to_s,
                  longitude: first_event.route_log.longitude.to_s,
                  speed: first_event.route_log.speed.to_s,
                  location_name: first_event.route_log.location_name,
                  sent_at: first_event.route_log.sent_at.iso8601,
                }
              },
              {
                type: 'trailer',
                attributes: {
                  device_serial_number: first_event.trailer.device_serial_number,
                  registration_number: first_event.trailer.registration_number,
                  device_installed_at: first_event.trailer.device_installed_at.iso8601,
                  make: first_event.trailer.make,
                  model: first_event.trailer.model,
                  description: first_event.trailer.description,
                  engine_running: first_event.trailer.engine_running
                }
              },
              {
                type: 'logistician',
                attributes: {
                  first_name: second_event.logistician.person.first_name,
                  last_name: second_event.logistician.person.last_name,
                }
              },
              {
                type: 'route_log',
                attributes: {
                  latitude: second_event.route_log.latitude.to_s,
                  longitude: second_event.route_log.longitude.to_s,
                  speed: second_event.route_log.speed.to_s,
                  location_name: second_event.route_log.location_name,
                  sent_at: second_event.route_log.sent_at.iso8601,
                }
              },
              {
                id: reaction_event.id.to_s,
                type: 'interaction',
                attributes: {
                  kind: reaction_event.kind
                },
                relationships: {
                  logistician: {
                    data: { id: reaction_event.logistician.id.to_s, type: 'logistician' }
                  }
                }
              },
              {
                type: 'logistician',
                id: reaction_event.logistician.id.to_s
              }
            ]
          )
        end
      end
    end
  end

  describe 'PATCH #resolve_alarm' do
    let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }
    let!(:event)  { create(:trailer_event, kind: :alarm, logistician: auth.logistician, trailer: trailer) }

    context 'with valid event ID' do
      let(:data) {
        {
          type: 'trailer_event',
          id: event.id.to_s,
          attributes: {
            kind: 'alarm'
          },
          relationships: {
            linked_event: { data: nil },
            interactions: { data: [{ type: 'interaction' }] },
            logistician:  { data: { id: auth.logistician.id.to_s, type: 'logistician' } }
          }
        }
      }

      let(:new_event) { ::TrailerEvent.last }

      let(:included_data) {
        [
          {
            id: new_event.id.to_s,
            type: 'interaction',
            attributes: {
              kind: 'alarm_resolved'
            }
          },
          {
            id: new_event.logistician.id.to_s,
            type: 'logistician',
            attributes: {
              first_name: new_event.logistician.person.first_name
            }
          }
        ]
      }

      before do
        patch :resolve_alarm, params: { id: event.id }
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns parent event data' do
        expect(parsed_response_body[:data]).to include_json(data)
      end

      it 'returns parent event included data' do
        expect(parsed_response_body[:included]).to include_json(included_data)
      end
    end

    context 'with invalid event ID' do
      before do
        patch :resolve_alarm, params: { id: -1 }
      end

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when alarm has been resolved' do
      let(:event) { create(:trailer_event, kind: :alarm_resolved, logistician: auth.logistician) }

      before do
        patch :resolve_alarm, params: { id: event.id }
      end

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors' do
        expect(parsed_response_body).to include_json(
          errors: [
            {
              title: 'Kind',
              detail: I18n.t('errors.included_in?.arg.default', list: 'alarm, quiet_alarm, emergency_call')
            }
          ]
        )
      end
    end

    context 'when logistician has no permission' do
      let(:trailer) { create(:trailer) }
      let!(:event)  { create(:trailer_event, kind: :alarm, trailer: trailer) }
      let!(:perm)   { create(:trailer_access_permission, logistician: auth.logistician, trailer: trailer, alarm_resolve_control: false) }

      before do
        patch :resolve_alarm, params: { id: event.id }
      end

      it 'returns 403' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
