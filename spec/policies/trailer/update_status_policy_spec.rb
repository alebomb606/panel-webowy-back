require 'rails_helper'

RSpec.describe Trailer::UpdateStatusPolicy do
  subject { described_class.permitted?(permission, status) }

  describe '#permitted?' do
    let(:trailer)     { create(:trailer) }
    let(:logistician) { create(:logistician) }

    context 'with unknown status' do
      let!(:permission) { create(:trailer_access_permission, trailer: trailer, logistician: logistician, alarm_control: true) }
      let(:status)      { 'asdadasdsadsa' }

      it 'returns false' do
        expect(subject).to be_falsey
      end
    end

    context 'with alarm permission' do
      context 'when disabled' do
        let!(:permission) { create(:trailer_access_permission, trailer: trailer, logistician: logistician, alarm_control: false) }
        let(:status)      { 'alarm' }

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end

      context 'when enabled' do
        let!(:permission) { create(:trailer_access_permission, trailer: trailer, logistician: logistician, alarm_control: true) }

        context 'for alarm status' do
          let(:status) { 'alarm' }

          it 'returns true' do
            expect(subject).to be_truthy
          end
        end

        context 'for alarm_silenced status' do
          let(:status) { 'alarm_silenced' }

          it 'returns true' do
            expect(subject).to be_truthy
          end
        end

        context 'for alarm_off status' do
          let(:status) { 'alarm_off' }

          it 'returns true' do
            expect(subject).to be_truthy
          end
        end
      end
    end

    context 'with alarm arm permission' do
      context 'when disabled' do
        let!(:permission) { create(:trailer_access_permission, trailer: trailer, logistician: logistician, system_arm_control: false) }
        let(:status)      { 'armed' }

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end

      context 'when enabled' do
        let!(:permission) { create(:trailer_access_permission, trailer: trailer, logistician: logistician, system_arm_control: true) }

        context 'for armed status' do
          let(:status) { 'armed' }

          it 'returns true' do
            expect(subject).to be_truthy
          end
        end

        context 'for disarmed status' do
          let(:status) { 'disarmed' }

          it 'returns true' do
            expect(subject).to be_truthy
          end
        end
      end
    end

    context 'with load in mode permission' do
      context 'when disabled' do
        let!(:permission) { create(:trailer_access_permission, trailer: trailer, logistician: logistician, load_in_mode_control: false) }
        let(:status)      { 'start_loading' }

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end

      context 'when enabled' do
        let!(:permission) { create(:trailer_access_permission, trailer: trailer, logistician: logistician, load_in_mode_control: true) }

        context 'for start loading status' do
          let(:status) { 'start_loading' }

          it 'returns true' do
            expect(subject).to be_truthy
          end
        end

        context 'for end loading status' do
          let(:status) { 'end_loading' }

          it 'returns true' do
            expect(subject).to be_truthy
          end
        end
      end
    end
  end
end
