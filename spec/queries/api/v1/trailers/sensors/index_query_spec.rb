require 'rails_helper'

RSpec.describe Api::V1::Trailers::Sensors::IndexQuery do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |r| r }
        m.failure(:trailer_not_found) { 'not found' }
        m.failure { |r| r }
      end
    end

    let(:auth)    { create(:auth, :with_logistician) }
    let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }
    let(:sensors) { create_list(:trailer_sensor, 3, trailer: trailer) }

    context 'with valid ID' do
      let(:params) { { trailer_id: trailer.id, auth: auth } }

      it 'returns mounted sensors' do
        expect(subject).to match_array(sensors)
      end

      it 'triggers the Api::Safeway::RequestSensors command' do
        expect(Api::Safeway::RequestSensors).to receive(:call).with(trailer)
        subject
      end
    end

    context 'with invalid ID' do
      let(:params) { { trailer_id: -1, auth: auth } }

      it 'returns not found' do
        expect(subject).to eq('not found')
      end
    end

    context 'with invalid params' do
      let(:params) { { trailer_id: nil, auth: nil } }
      let(:errors) { subject[:errors] }

      it 'returns errors' do
        expect(errors[:trailer_id]).to include(I18n.t('errors.filled?'))
        expect(errors[:auth]).to include(I18n.t('errors.filled?'))
      end
    end

    context 'when no permissions' do
      let(:trailer) { create(:trailer) }
      let(:params)  { { trailer_id: trailer.id, auth: auth } }

      it 'returns not found' do
        expect(subject).to eq('not found')
      end
    end
  end
end
