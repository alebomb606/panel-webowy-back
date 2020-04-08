require 'rails_helper'

RSpec.describe TrailerSensorReading::Formatter do
  describe '#call' do
    subject { described_class.new(reading) }

    context 'with valid reading' do
      let(:reading) { create(:trailer_sensor_reading, original_value: 15, sensor: sensor ) }

      let!(:sensor_setting) {
        create(:trailer_sensor_setting,
          sensor: sensor,
          alarm_primary_value: 20,
          warning_primary_value: 50
        )
      }

      context 'for percentage sensor' do
        let(:sensor) { create(:trailer_sensor, kind: :safeway_battery) }

        it 'returns valid values' do
          expect(subject.status).to eq(:alarm)
          expect(subject.percentage).to eq(reading.original_value)
          expect(subject.value).to eq(reading.original_value)
        end
      end

      context 'for special sensor' do
        context 'for co2' do
          let!(:sensor_setting) {
            create(:trailer_sensor_setting,
              sensor: sensor,
              alarm_primary_value: 30,
              warning_primary_value: 20
            )
          }

          let(:sensor) { create(:trailer_sensor, kind: :co2) }

          context 'ok state' do
            let(:reading) { create(:trailer_sensor_reading, original_value: 15, sensor: sensor ) }

            it 'returns valid values' do
              expect(subject.status).to eq(:ok)
              expect(subject.percentage).to eq(15.0)
              expect(subject.value).to eq(15.0)
            end
          end

          context 'warning state' do
            let(:reading) { create(:trailer_sensor_reading, original_value: 25, sensor: sensor ) }

            it 'returns valid values' do
              expect(subject.status).to eq(:warning)
              expect(subject.percentage).to eq(25.0)
              expect(subject.value).to eq(25.0)
            end
          end

          context 'alarm state' do
            let(:reading) { create(:trailer_sensor_reading, original_value: 40, sensor: sensor ) }

            it 'returns valid values' do
              expect(subject.status).to eq(:alarm)
              expect(subject.percentage).to eq(40.0)
              expect(subject.value).to eq(40.0)
            end
          end
        end

        context 'for data transfer' do
          let!(:sensor_setting) {
            create(:trailer_sensor_setting,
              sensor: sensor,
              alarm_primary_value: 1,
              warning_primary_value: 2
            )
          }

          let(:sensor) { create(:trailer_sensor, kind: :data_transfer) }

          context 'ok state' do
            let(:reading) { create(:trailer_sensor_reading, original_value: 1, maximum_value: 4, sensor: sensor ) }

            it 'returns valid values' do
              expect(subject.status).to eq(:ok)
              expect(subject.percentage).to eq(75.0)
              expect(subject.value).to eq(3.0)
            end
          end

          context 'warning state' do
            let(:reading) { create(:trailer_sensor_reading, original_value: 2.1, maximum_value: 4, sensor: sensor ) }

            it 'returns valid values' do
              expect(subject.status).to eq(:warning)
              expect(subject.percentage).to eq(47.5)
              expect(subject.value).to eq(1.9)
            end
          end

          context 'alarm state' do
            let(:reading) { create(:trailer_sensor_reading, original_value: 3.5, maximum_value: 4, sensor: sensor ) }

            it 'returns valid values' do
              expect(subject.status).to eq(:alarm)
              expect(subject.percentage).to eq(12.5)
              expect(subject.value).to eq(0.5)
            end
          end
        end

        context 'for temperature' do
          let!(:sensor_setting) {
            create(:trailer_sensor_setting,
              sensor: sensor,
              alarm_primary_value: 0,
              alarm_secondary_value: 50,
              warning_primary_value: 10,
              warning_secondary_value: 40
            )
          }

          let(:sensor) { create(:trailer_sensor, kind: :trailer_temperature) }

          context 'warning state' do
            let(:reading) { create(:trailer_sensor_reading, original_value: 5, sensor: sensor ) }

            it 'returns valid values' do
              expect(subject.status).to eq(:warning)
              expect(subject.percentage).to eq(10.0)
              expect(subject.value).to eq(reading.original_value)
            end
          end

          context 'alarm state' do
            let(:reading) { create(:trailer_sensor_reading, sensor: sensor, original_value: 60 ) }

            it 'returns valid values' do
              expect(subject.status).to eq(:alarm)
              expect(subject.percentage).to eq(100)
              expect(subject.value).to eq(reading.original_value)
            end
          end

          context 'ok state' do
            let(:reading) { create(:trailer_sensor_reading, sensor: sensor, original_value: 20 ) }

            it 'returns valid values' do
              expect(subject.status).to eq(:ok)
              expect(subject.percentage).to eq(40.0)
              expect(subject.value).to eq(reading.original_value)
            end
          end
        end
      end
    end
  end
end
