require 'rails_helper'

RSpec.describe Api::V1::Trailers::Sensors::FetchQuery do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |r| r }
        m.failure(:forbidden) { 'forbidden' }
        m.failure(:sensor_not_found) { 'sensor not found' }
        m.failure(:trailer_not_found) { 'trailer not found - forbidden' }
        m.failure(:no_permission) { 'no permission' }
        m.failure { |r| r }
      end
    end

    let(:auth)    { create(:auth, :with_logistician) }
    let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }
    let(:sensor)  { create(:trailer_sensor, trailer: trailer) }

    context 'with valid ID' do
      let(:params) { { id: sensor.id, auth: auth } }

      it 'returns sensor' do
        expect(subject).to eq(sensor)
      end

      it 'triggers the Api::Safeway::RequestSensors command' do
        expect(Api::Safeway::RequestSensors).to receive(:call).with(trailer)
        subject
      end
    end

    context 'with invalid ID' do
      let(:params) { { id: -1, auth: auth } }

      it 'returns not found' do
        expect(subject).to eq('sensor not found')
      end
    end

    context 'with invalid params' do
      let(:params) { { id: nil, auth: nil } }
      let(:errors) { subject[:errors] }

      it 'returns errors' do
        expect(errors[:id]).to include(I18n.t('errors.filled?'))
        expect(errors[:auth]).to include(I18n.t('errors.filled?'))
      end
    end

    context 'when no trailer permission found' do
      let(:trailer) { create(:trailer) }
      let(:params)  { { id: sensor.id, auth: auth } }

      it 'returns forbidden' do
        expect(subject).to eq('trailer not found - forbidden')
      end
    end

    context 'without necessary permission' do
      let(:trailer) { create(:trailer) }
      let!(:perm)   { create(:trailer_access_permission, sensor_access: false, logistician: auth.logistician, trailer: trailer) }
      let(:sensor)  { create(:trailer_sensor, trailer: trailer) }
      let(:params)  { { id: sensor.id, auth: auth } }

      it 'returns forbidden' do
        expect(subject).to eq('no permission')
      end
    end
  end
end
