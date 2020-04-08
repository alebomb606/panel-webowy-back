require 'rails_helper'

RSpec.describe TrailerEvent::LogInteraction do
  describe '#call' do
    subject do
      described_class.new(trailer, params).call
    end

    let(:logistician) { create(:logistician, :with_auth) }
    let(:trailer)     { create(:trailer, status: :start_loading) }

    context 'when trailer has loading status' do
      let!(:event) { create(:trailer_event, trailer: trailer, kind: :start_loading) }
      let(:end_loading_event) { ::TrailerEvent.find_by(kind: 'end_loading') }

      let(:params) {
        {
          kind: 'alarm',
          logistician: logistician
        }
      }

      let(:triggered_at) { Time.current }
      let(:uuid)         { SecureRandom.uuid }

      before do
        allow(Time).to receive(:current).and_return(triggered_at)
        allow(SecureRandom).to receive(:uuid).and_return(uuid)
      end

      it 'creates end loading event and specified one' do
        expect { subject }.to change { ::TrailerEvent.count }.by(2)
        expect(::TrailerEvent.where.not(id: event.id).pluck(:kind)).to match_array(%w[alarm end_loading])
      end

      it 'creates event with default uuid and triggered_at' do
        expect(subject).to have_attributes(uuid: uuid, triggered_at: triggered_at)
      end

      it 'interacts end_loading with start_loading' do
        subject
        expect(end_loading_event.linked_event).to eq(event)
      end
    end

    context 'with alarming reading passed' do
      let!(:sensor)  { create(:trailer_sensor, trailer: trailer, kind: :safeway_battery) }
      let!(:reading) { create(:trailer_sensor_reading, sensor: sensor, status: :alarm) }

      let(:params) do
        {
          kind: 'alarm',
          sensor_reading: reading
        }
      end

      it 'creates event with reading' do
        expect(subject).to have_attributes(sensor_reading: reading, kind: 'alarm')
      end

      context 'with subsequent alarming reading' do
        let!(:reading_2) { create(:trailer_sensor_reading, sensor: sensor, status: :alarm, read_at: 10.minutes.ago) }

        it 'does not log event' do
          expect { subject }.not_to change { ::TrailerEvent.count }
        end
      end

      context 'when previous reading is ok' do
        let!(:reading_2) { create(:trailer_sensor_reading, sensor: sensor, status: :ok, read_at: 10.minutes.ago) }

        it 'creates new event' do
          expect { subject }.to change { ::TrailerEvent.count }.by(1)
        end
      end

      context 'when previous reading is warning' do
        let!(:reading_2) { create(:trailer_sensor_reading, sensor: sensor, status: :warning, read_at: 10.minutes.ago) }

        it 'creates new event' do
          expect { subject }.to change { ::TrailerEvent.count }.by(1)
        end
      end
    end
  end
end
