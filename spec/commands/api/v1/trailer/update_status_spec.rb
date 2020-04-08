require 'rails_helper'

RSpec.describe Api::V1::Trailer::UpdateStatus do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |res| res }
        m.failure(:trailer_not_found) { 'not found' }
        m.failure(:no_permission) { 'no permission' }
        m.failure { |res| res }
      end
    end

    let(:auth)    { create(:auth, :with_logistician) }
    let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician, status: :alarm_silenced) }

    context 'with valid params' do
      let(:params) { { 'id' => trailer.id, 'status' => 'alarm', 'auth' => auth } }
      let(:serialized_trailer) {
        {
          data: [{
            id: trailer.id.to_s,
            type: 'trailer',
            attributes: {}
          }]
        }
      }

      it 'updates trailer status' do
        expect { subject }.to change { trailer.reload.status }.to('alarm')
      end

      it 'creates new event' do
        expect { subject }.to change { ::TrailerEvent.count }.by(1)
      end

      it 'assigns a logistician to newly created event' do
        subject
        expect(::TrailerEvent.last.logistician).to eq(auth.logistician)
      end

      it 'broadcasts WS message' do
        expect { subject }.to have_broadcasted_to("auths_#{auth.id}")
          .with(include_json(serialized_trailer))
      end

      context 'with log' do
        let!(:log) { create(:route_log, trailer: trailer) }

        it 'creates route log for event' do
          expect { subject }.to change { ::RouteLog.count }.by(1)
        end

        it 'has valid attributes' do
          subject
          expect(::RouteLog.order(sent_at: :desc).first).to have_attributes(
            latitude: log.latitude,
            longitude: log.longitude,
            location_name: log.location_name,
            speed: log.speed,
            locale: log.locale
          )
        end

        context 'with loading in progess' do
          let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician, status: 'start_loading' ) }
          let(:params) { { 'id' => trailer.id, 'status' => 'armed', 'auth' => auth } }

          before do
            create(:trailer_event, kind: 'start_loading', trailer: trailer)
          end

          it 'adds two events' do
            expect { subject } .to change { TrailerEvent.count }.by(2)
          end

          it 'ends started loading' do
            subject
            expect(trailer.loading_in_progress?).to be_falsy
          end
        end
      end

      context 'with quiet alarm on' do
        let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician, status: 'quiet_alarm' ) }

        context 'when turning off an alarm' do
          let(:params) { { 'id' => trailer.id, 'status' => 'alarm_off', 'auth' => auth } }

          it 'changes trailer status' do
            expect(subject.status).to eq('alarm_off')
          end

          it 'adds one event' do
            expect { subject }.to change { ::TrailerEvent.count }.by(1)
          end
        end

        context 'when trying to start loading' do
          let(:params) { { 'id' => trailer.id, 'status' => 'start_loading', 'auth' => auth } }
          let(:errors) { subject[:errors] }

          it 'returns error' do
            expect(errors[:status]).to include(I18n.t('errors.included_in?.arg.default', list: 'alarm, alarm_off, emergency_call'))
          end

          it 'does not change status' do
            expect(trailer.reload.status).to eq 'quiet_alarm'
          end

          it 'does not add event' do
            expect { subject }.not_to change { ::TrailerEvent.count }
          end
        end
      end

      context 'without log' do
        it 'does not create route log for event' do
          expect { subject }.not_to change { ::RouteLog.count }
        end
      end

      context 'without needed permission' do
        let(:trailer) { create(:trailer, status: :alarm_silenced) }

        context 'with no alarm control permission' do
          let!(:perm)  { create(:trailer_access_permission, trailer: trailer, logistician: auth.logistician, alarm_control: false) }
          let(:params) { { 'id' => trailer.id, 'status' => 'alarm', 'auth' => auth } }

          it 'returns no permission error' do
            expect(subject).to eq('no permission')
          end
        end

        context 'with no system arm control permission' do
          let!(:perm)  { create(:trailer_access_permission, trailer: trailer, logistician: auth.logistician, system_arm_control: false) }
          let(:params) { { 'id' => trailer.id, 'status' => 'disarmed', 'auth' => auth } }

          it 'returns no permission error' do
            expect(subject).to eq('no permission')
          end
        end

        context 'with no load control permission' do
          let!(:perm)  { create(:trailer_access_permission, trailer: trailer, logistician: auth.logistician, load_in_mode_control: false) }
          let(:params) { { 'id' => trailer.id, 'status' => 'end_loading', 'auth' => auth } }

          it 'returns no permission error' do
            expect(subject).to eq('no permission')
          end
        end
      end
    end

    context 'with linking events' do
      let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician, status: :alarm) }

      context 'when turning off an alarm' do
        let(:params) { { 'id' => trailer.id, 'status' => 'alarm_off', 'auth' => auth } }
        let!(:alarm_event) { create(:trailer_event, kind: :alarm, trailer: trailer) }

        it 'creates a new event and associates it with previous alarm' do
          subject
          expect(TrailerEvent.last.linked_event).to eq(alarm_event)
          expect(alarm_event.interactions).to include(TrailerEvent.last)
        end
      end

      context 'when silencing an alarm' do
        let(:params) { { 'id' => trailer.id, 'status' => 'alarm_silenced', 'auth' => auth } }
        let!(:alarm_event) { create(:trailer_event, kind: :alarm, trailer: trailer) }

        it 'creates a new event and associates it with previous alarm' do
          subject
          expect(TrailerEvent.last.linked_event).to eq(alarm_event)
          expect(alarm_event.interactions).to include(TrailerEvent.last)
        end
      end

      context 'when resolving quiet alarm' do
        let(:params) { { 'id' => trailer.id, 'status' => 'alarm_silenced', 'auth' => auth } }
        let!(:alarm_event) { create(:trailer_event, kind: :quiet_alarm, trailer: trailer) }

        it 'creates a new event and associates it with previous alarm' do
          subject
          expect(TrailerEvent.last.linked_event).to eq(alarm_event)
          expect(alarm_event.interactions).to include(TrailerEvent.last)
        end
      end

      context 'when turning off the loading mode' do
        let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician, status: :start_loading) }
        let(:params) { { 'id' => trailer.id, 'status' => 'end_loading', 'auth' => auth } }
        let!(:loading_event) { create(:trailer_event, kind: :start_loading, trailer: trailer) }

        it 'creates a new event and associates it with previous loading mode enable' do
          subject
          expect(TrailerEvent.last.linked_event).to eq(loading_event)
          expect(loading_event.interactions).to include(TrailerEvent.last)
        end
      end

      context 'when disarming the system' do
        let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician, status: :armed) }
        let(:params) { { 'id' => trailer.id, 'status' => 'disarmed', 'auth' => auth } }
        let!(:arm_event) { create(:trailer_event, kind: :armed, trailer: trailer) }

        it 'creates a new event and associates it with previous arming' do
          subject
          expect(TrailerEvent.last.linked_event).to eq(arm_event)
          expect(arm_event.interactions).to include(TrailerEvent.last)
        end
      end

      context 'when turning off the emergency call' do
        let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician, status: :emergency_call) }
        let(:params) { { 'id' => trailer.id, 'status' => 'alarm_off', 'auth' => auth } }
        let!(:emergency_event) { create(:trailer_event, kind: :emergency_call, trailer: trailer) }

        it 'creates a new event and associates it with previous emergency call' do
          subject
          expect(TrailerEvent.last.linked_event).to eq(emergency_event)
          expect(emergency_event.interactions).to include(TrailerEvent.last)
        end
      end
    end

    context 'with invalid params' do
      let(:errors) { subject[:errors] }

      context 'with status that is not transformable at the moment' do
        let(:params) { { 'auth' => auth, 'id' => trailer.id, 'status' => 'end_loading' } }

        it 'returns error' do
          expect(errors[:status]).to include(I18n.t('errors.included_in?.arg.default', list: 'alarm, alarm_off, emergency_call'))
        end
      end

      context 'with same status as now' do
        let(:params) { { 'auth' => auth, 'id' => trailer.id, 'status' => trailer.status } }

        it 'returns error' do
          expect(errors[:status]).to include(I18n.t('errors.included_in?.arg.default', list: 'alarm, alarm_off, emergency_call'))
          expect(errors[:status]).to include(I18n.t('errors.not_eql?', left: trailer.status))
        end
      end

      context 'with invalid trailer id' do
        let(:params) { { 'id' => -1, 'status' => 'alarm', 'auth' => auth } }

        it 'returns not found' do
          expect(subject).to eq('not found')
        end
      end

      context 'with invalid status' do
        let(:params) { { 'id' => '', 'status' => 'ZŁY STATUS', 'auth' => nil } }

        it 'returns errors' do
          expect(errors[:status]).to include(
            I18n.t('errors.included_in?.arg.default', list: ::Trailer.statuses.keys.join(', '))
          )
          expect(errors[:id]).to include(I18n.t('errors.filled?'))
          expect(errors[:auth]).to include(I18n.t('errors.filled?'))
        end
      end
    end
  end
end
