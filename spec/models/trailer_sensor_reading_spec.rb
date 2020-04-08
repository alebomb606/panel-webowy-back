require 'rails_helper'

RSpec.describe TrailerSensorReading, type: :model do
  describe '#event_triggerable?' do
    let(:trailer) { create(:trailer, status: :alarm_off) }
    let(:sensor)  { create(:trailer_sensor, trailer: trailer) }

    context 'with alarm status' do
      subject { create(:trailer_sensor_reading, sensor: sensor, status: :alarm, read_at: 10.minutes.ago) }

      context 'when previous is ok' do
        let!(:reading) { create(:trailer_sensor_reading, sensor: sensor, status: :ok, read_at: 20.minutes.ago) }

        it 'returns true' do
          expect(subject.event_triggerable?).to be_truthy
        end
      end

      context 'when previous is warning' do
        let!(:reading) { create(:trailer_sensor_reading, sensor: sensor, status: :warning, read_at: 20.minutes.ago) }

        it 'returns true' do
          expect(subject.event_triggerable?).to be_truthy
        end
      end
    end

    context 'with warning status' do
      subject { create(:trailer_sensor_reading, sensor: sensor, status: :warning, read_at: 10.minutes.ago) }

      context 'when previous is ok' do
        let!(:reading) { create(:trailer_sensor_reading, sensor: sensor, status: :ok, read_at: 20.minutes.ago) }

        context 'when trailer has alarm enabled' do
          let(:trailer) { create(:trailer, status: :quiet_alarm) }

          before do
            create(:trailer_sensor_reading, sensor: sensor, status: :alarm, read_at: 20.minutes.ago)
          end

          it 'returns false' do
            expect(subject.event_triggerable?).to be_falsey
          end
        end

        it 'returns true' do
          expect(subject.event_triggerable?).to be_truthy
        end
      end

      context 'when previous is warning' do
        let!(:reading) { create(:trailer_sensor_reading, sensor: sensor, status: :warning, read_at: 20.minutes.ago) }

        it 'returns false' do
          expect(subject.event_triggerable?).to be_falsey
        end
      end

      context 'when previous is alarm' do
        let!(:reading) { create(:trailer_sensor_reading, sensor: sensor, status: :alarm, read_at: 20.minutes.ago) }

        it 'returns false' do
          expect(subject.event_triggerable?).to be_falsey
        end
      end
    end
  end
end
