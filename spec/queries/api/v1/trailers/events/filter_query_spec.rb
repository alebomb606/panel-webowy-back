require 'rails_helper'

RSpec.describe Api::V1::Trailers::Events::FilterQuery do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |r| r }
        m.failure(:trailer_not_found) { 'not found' }
        m.failure(:no_permission) { 'no permission' }
        m.failure { |r| r }
      end
    end

    let(:auth)    { create(:auth, :with_logistician) }
    let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }

    context 'with valid params' do
      context 'filter by dates' do
        let!(:event_1) { create(:trailer_event, trailer: trailer, triggered_at: 30.minutes.ago) }
        let!(:event_2) { create(:trailer_event, trailer: trailer, triggered_at: 29.minutes.ago) }
        let!(:event_3) { create(:trailer_event, trailer: trailer, triggered_at: 28.minutes.ago) }
        let!(:event_4) { create(:trailer_event, trailer: trailer, triggered_at: 10.minutes.ago) }

        let(:params) {
          {
            auth: auth,
            trailer_id: trailer.id,
            filter: {
              date_from: event_1.triggered_at.iso8601,
              date_to: (event_1.triggered_at + 5.minutes).iso8601,
              kinds: ::TrailerEvent.kinds.keys.join(',')
            }
          }
        }

        it 'returns records filtered by date' do
          expect(subject).to eq([event_3, event_2, event_1])
        end
      end

      context 'filter by kinds' do
        let!(:event_1) { create(:trailer_event, trailer: trailer, kind: :start_loading, triggered_at: 5.minutes.ago) }
        let!(:event_2) { create(:trailer_event, trailer: trailer, kind: :armed, triggered_at: 3.hours.ago) }
        let!(:event_3) { create(:trailer_event, trailer: trailer, kind: :disarmed, triggered_at: 10.hours.ago) }
        let!(:event_4) { create(:trailer_event, trailer: trailer, kind: :warning, triggered_at: 23.hours.ago) }

        let(:params) {
          {
            auth: auth,
            trailer_id: trailer.id,
            filter: {
              kinds: "#{event_1.kind}, #{event_2.kind}"
            }
          }
        }

        it 'returns records filtered by kind' do
          expect(subject).to eq([event_1, event_2])
        end
      end
    end

    context 'without additional params' do
      let!(:event_1) { create(:trailer_event, trailer: trailer, triggered_at: 5.days.ago) }
      let!(:event_2) { create(:trailer_event, trailer: trailer, triggered_at: 2.days.ago) }
      let!(:event_3) { create(:trailer_event, trailer: trailer, triggered_at: 30.minutes.ago) }
      let!(:event_4) { create(:trailer_event, trailer: trailer, triggered_at: 10.hours.ago) }

      let(:params) { { auth: auth, trailer_id: trailer.id } }

      it 'returns no events by default' do
        expect(subject).to be_empty
      end
    end

    context 'with invalid params' do
      context 'with blank params' do
        let(:params) {
          {
            auth: auth,
            trailer_id: trailer.id,
            filter: { 
              date_from: '',
              date_to: '',
              kinds: ''
            }
          }
        }

        let(:errors) { subject[:errors][:filter] }

        it 'returns errors' do
          expect(errors[:date_from]).to include(I18n.t('errors.filled?'))
          expect(errors[:date_to]).to include(I18n.t('errors.filled?'))
          expect(errors[:kinds]).to be_nil
        end
      end

      context 'with from date after to date' do
        let(:params) {
          {
            trailer_id: trailer.id,
            filter: {            
              date_from: Time.current.iso8601,
              date_to: 30.minutes.ago.iso8601
            }
          }
        }

        it 'returns errors' do
          expect(subject[:errors][:filter][:date_from]).to include(I18n.t('errors.from_before_to?'))
        end
      end

      context 'with invalid kinds' do
        let(:params) { { trailer_id: trailer.id, filter: { kinds: 'a, b' } } }
        let(:errors) { subject[:errors][:filter][:kinds] }
        let(:error)  { I18n.t('errors.included_in?.arg.default', list: ::TrailerEvent.kinds.keys.join(', ')) }

        it 'returns errors' do
          expect(errors[0]).to include(error)
          expect(errors[1]).to include(error)
        end
      end

      context 'with invalid trailer ID' do
        let(:params)  { { auth: auth, trailer_id: -1 } }

        it 'returns error' do
          expect(subject).to eq('not found')
        end
      end

      context 'without necessary permission' do
        let!(:perm)   { create(:trailer_access_permission, event_log_access: false, logistician: auth.logistician, trailer: trailer) }
        let(:trailer) { create(:trailer) }
        let(:params)  { { auth: auth, trailer_id: trailer.id } }

        it 'returns error' do
          expect(subject).to eq('no permission')
        end
      end
    end
  end
end
