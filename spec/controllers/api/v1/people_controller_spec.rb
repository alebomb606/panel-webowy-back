require 'rails_helper'

RSpec.describe Api::V1::PeopleController do
  let(:auth)         { create(:auth) }
  let!(:logistician) { create(:logistician, auth: auth) }
  let!(:person)      { create(:person, phone_number: '+48515171717', personifiable: logistician) }

  before do
    set_jsonapi_headers
    set_auth_headers(auth)
  end

  describe 'GET #index' do
    context 'with filter param passed' do
      let(:params) { { 'filter' => { 'phone_number' => '515' } } }
      let(:response_data) do
        [
          {
            id: person.id.to_s,
            type: 'person',
            attributes: {
              first_name: person.first_name,
              last_name: person.last_name,
              phone_number: person.phone_number,
              position: 'logistician'
            }
          }
        ]
      end

      before do
        get :index, params: params
      end

      it 'returns matching data' do
        expect(parsed_response_body[:data]).to include_json(response_data)
      end
    end

    context 'without filter param passed' do
      let(:response_data) do
        person.company.people.map do |person|
          {
            id: person.id.to_s,
            type: 'person',
            attributes: {
              first_name: person.first_name,
              last_name: person.last_name,
              phone_number: person.phone_number,
              position: 'logistician'
            }
          }
        end
      end

      before do
        2.times { create(:person, personifiable: create(:logistician, :with_auth), company: person.company) }

        get :index
      end

      it 'returns matching data' do
        expect(parsed_response_body[:data]).to match_unordered_json(response_data)
      end
    end

    context 'with invalid params' do
      let(:params) { { filter: { keyword: '' } } }

      before do
        get :index, params: params
      end

      it 'returns 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
