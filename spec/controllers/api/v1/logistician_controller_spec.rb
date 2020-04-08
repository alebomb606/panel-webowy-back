require 'rails_helper'

RSpec.describe Api::V1::LogisticianController do
  let!(:auth)  { create(:auth, :with_logistician) }
  let(:person) { auth.logistician.person }

  before do
    set_jsonapi_headers
    set_auth_headers(auth)
  end

  let(:data) {
    {
      type: 'logistician',
      id: auth.logistician.id.to_s,
      attributes: attributes
    }
  }

  describe 'GET #show' do
    let!(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }
    let(:attributes) {
      {
        preferred_locale: 'pl'
      }
    }

    let(:permission) { trailer.access_permissions.first }
    let(:included_data) {
      [
        {
          id: person.id.to_s,
          type: 'person',
          attributes: {
            first_name: person.first_name,
            last_name: person.last_name,
            phone_number: person.phone_number,
            extra_phone_number: person.extra_phone_number,
            email: person.email,
            avatar_url: person.avatar.url,
            position: person.personifiable_type.underscore
          }
        },
        {
          id: permission.id.to_s,
          type: 'trailer_access_permission',
          attributes: {
            sensor_access: permission.sensor_access,
            event_log_access: permission.event_log_access,
            alarm_control: permission.alarm_control,
            alarm_resolve_control: permission.alarm_resolve_control,
            system_arm_control: permission.system_arm_control,
            load_in_mode_control: permission.load_in_mode_control,
            photo_download: permission.photo_download,
            video_download: permission.video_download,
            monitoring_access: permission.monitoring_access,
            current_position: permission.current_position,
            route_access: permission.route_access
          }
        }
      ]
    }

    before do
      get :show
    end

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns logistician data' do
      expect(parsed_response_body[:data]).to include_json(data)
    end

    it 'returns included data' do
      expect(parsed_response_body[:included]).to match_unordered_json(included_data)
    end
  end

  describe 'PATCH #update' do
    let(:params) { { _jsonapi: { data: data } } }

    context 'with valid params' do
      let(:attributes) { attributes_for(:person, :with_base64_avatar) }
      let(:included_data) {
        person.reload
        [
          {
            id: person.id.to_s,
            type: 'person',
            attributes: {
              first_name: person.first_name,
              last_name: person.last_name,
              phone_number: person.phone_number,
              extra_phone_number: person.extra_phone_number,
              email: person.email
            }
          }
        ]
      }

      before do
        patch :update, params: params.deep_merge(
          _jsonapi: { data: { attributes: { password: 'password1234' } } }
        )
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns updated logistician data' do
        expect(parsed_response_body[:data]).to include_json(attributes: { preferred_locale: 'pl' })
      end

      it 'returns included logistician data' do
        expect(parsed_response_body[:included]).to match_unordered_json(included_data)
      end
    end

    context 'with invalid params' do
      let(:attributes) { {} }

      before do
        patch :update, params: params
      end

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update_password' do
    let(:params) { { _jsonapi: { data: data } } }

    context 'with valid params' do
      let(:attributes) { { current_password: 'password1234', password: '12345678', password_confirmation: '12345678' } }

      before do
        patch :update_password, params: params
      end

      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      let(:attributes) { { password: '' } }
      let(:errors)     { parsed_response_body[:errors] }

      before do
        patch :update_password, params: params
      end

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders specific errors' do
        expect(errors).to include_json([
          {
            title: I18n.t('errors.attributes.current_password'),
            detail: I18n.t('errors.key?')
          },
          {
            title: I18n.t('errors.attributes.password'),
            detail: I18n.t('errors.filled?')
          }
        ])
      end

      context 'with invalid password' do
        let(:attributes) { { current_password: 'asd', password: '12345678', password_confirmation: '12345678' } }

        it 'returns 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders specific error' do
          expect(errors).to include_json([{
            title: I18n.t('errors.attributes.current_password'),
            detail: I18n.t('errors.valid_password?')
          }])
        end
      end
    end
  end
end
