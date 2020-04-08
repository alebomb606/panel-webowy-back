require 'rails_helper'

RSpec.describe Trailer, type: :model do
  describe 'methods' do
    describe '.makes_for_select_box' do
      it 'returns proper array of arrays' do
        expect(Trailer.makes_for_select_box).to eq [
          ['wielton', 'wielton'],
          ['schmitz', 'schmitz'],
          ['kogel', 'kogel'],
          ['wabash', 'wabash'],
          ['great_dane', 'great_dane'],
          ['abc', 'abc']
        ]
      end
    end

    describe '#transformable_statuses' do
      subject { trailer.transformable_statuses }

      context 'with interactable status' do
        let(:trailer) { create(:trailer) }

        it 'returns valid statuses' do
          ::Trailer::INTERACTIONS.keys.each do |status|
            trailer.update(status: status)
            expect(subject).to match_array(['start_loading', 'alarm', 'armed', 'emergency_call', 'quiet_alarm', 'alarm_resolved', 'shutdown_immediate', 'shutdown_pending', 'truck_battery_low', 'truck_battery_normal', 'truck_connected', 'truck_disconnected', 'engine_off', 'engine_on', 'parking_on', 'parking_off'])
          end
        end
      end

      context 'with alarm silenced status' do
        let(:trailer) { create(:trailer, status: :alarm_silenced) }

        it 'returns valid statuses' do
          expect(subject).to match_array(['alarm', 'alarm_off', 'emergency_call'])
        end
      end

      context 'with emergency_call status' do
        let(:trailer) { create(:trailer, status: :emergency_call) }

        it 'returns valid statuses' do
          expect(subject).to match_array(['alarm_silenced', 'alarm_off'])
        end
      end

      context 'with alarm status' do
        let(:trailer) { create(:trailer, status: :alarm) }

        it 'returns valid statuses' do
          expect(subject).to match_array(['alarm_silenced', 'alarm_off', 'emergency_call'])
        end
      end

      context 'with start_loading status' do
        let(:trailer) { create(:trailer, status: :start_loading) }

        it 'returns valid statuses' do
          expect(subject).to match_array(['end_loading', 'alarm', 'armed', 'emergency_call', 'quiet_alarm', 'alarm_resolved', 'shutdown_immediate', 'shutdown_pending', 'truck_battery_low', 'truck_battery_normal', 'truck_connected', 'truck_disconnected', 'engine_off', 'engine_on', 'parking_on', 'parking_off'])
        end
      end

      context 'with armed status' do
        let(:trailer) { create(:trailer, status: :armed) }

        it 'returns valid statuses' do
          expect(subject).to match_array(['start_loading', 'alarm', 'disarmed', 'quiet_alarm', 'emergency_call', 'alarm_resolved', 'shutdown_immediate', 'shutdown_pending', 'truck_battery_low', 'truck_battery_normal', 'truck_connected', 'truck_disconnected', 'engine_off', 'engine_on', 'parking_on', 'parking_off'])
        end
      end

      context 'with quiet_alarm' do
        let(:trailer) { create(:trailer, status: :quiet_alarm) }

        it 'returns valid statuses' do
          expect(subject).to match_array(['alarm', 'alarm_off', 'emergency_call'])
        end
      end
    end
  end

  describe 'scopes' do
    describe '.active' do
      let!(:trailer) { create(:trailer) }
      let!(:archived_trailer) { create(:trailer, :archived) }

      it 'returns only active records' do
        expect(Trailer.active).to eq [trailer]
      end
    end
  end
end
