require 'rails_helper'

RSpec.describe Api::V1::TrailerEvent::ResolveAlarm do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |res| res }
        m.failure(:event_not_found) { 'not found' }
        m.failure(:no_permission) { 'no permission' }
        m.failure { |res| res }
      end
    end

    let(:auth)    { create(:auth, :with_logistician) }
    let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }
    let!(:event)  { create(:trailer_event, kind: :alarm, logistician: nil, trailer: trailer) }

    context 'with valid params' do
      let(:params) { { 'id' => event.id, 'auth' => auth } }
      let(:logistician_2) { create(:logistician, :with_auth) }

      let(:websocket_data) do
        {
          data: [
            {
              id: event.id.to_s,
              type: 'trailer_event',
              attributes: { kind: 'alarm' },
            }
          ],
          included: [
            {
              type: 'interaction',
              attributes: { kind: 'alarm_resolved' }
            },
            {
              id: auth.logistician.id.to_s,
              type: 'logistician'
            }
          ]
        }
      end

      before do
        create(:trailer_access_permission, trailer: trailer, logistician: logistician_2)
      end

      it 'creates new event' do
        expect { subject }.to change { ::TrailerEvent.count }.by(1)
      end

      it 'saves event data' do
        expect(subject).to have_attributes(
          kind: 'alarm_resolved',
          logistician: auth.logistician,
          linked_event: event
        )
      end

      it 'saves interaction for alarm event' do
        expect(subject.linked_event.interactions).to eq([subject])
      end

      it 'broadcast WS message to logistician' do
        expect { subject }.to have_broadcasted_to("auths_#{logistician_2.auth.id}")
          .with(include_json(websocket_data))
      end
    end

    context 'with invalid params' do
      context 'with invalid event id' do
        let(:params) { { 'id' => '-1', 'auth' => auth } }

        it 'returns not found' do
          expect(subject).to eq('not found')
        end
      end

      context 'when event is already resolved' do
        let(:event)  { create(:trailer_event, kind: :alarm_resolved) }
        let(:params) { { 'id' => event.id, 'auth' => auth } }

        it 'returns error' do
          expect(subject[:errors][:kind]).to include(I18n.t('errors.included_in?.arg.default', list: 'alarm, quiet_alarm, emergency_call'))
        end
      end

      context 'when logistician has no permission' do
        let(:trailer) { create(:trailer) }
        let!(:perm)   { create(:trailer_access_permission, logistician: auth.logistician, trailer: trailer, alarm_resolve_control: false) }
        let(:params)  { { 'id' => event.id, 'auth' => auth } }

        it 'returns error' do
          expect(subject).to eq('no permission')
        end
      end
    end
  end
end
