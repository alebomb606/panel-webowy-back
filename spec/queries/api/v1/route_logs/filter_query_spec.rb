require 'rails_helper'

RSpec.describe Api::V1::Trailers::RouteLogs::FilterQuery do
  describe '#call' do
    subject do
      described_class.new.call(params) do |r|
        r.success { |logs| logs }
        r.failure(:trailer_not_found) { 'Trailer not found' }
        r.failure { |res| res }
      end
    end

    let(:auth)    { create(:auth, :with_logistician) }
    let(:trailer) { create(:trailer, :with_permission, permission_logistician: auth.logistician) }

    context 'when valid params are passed' do
      context 'without filter passed' do
        let!(:log_1) { create(:route_log, trailer_id: trailer.id, sent_at: (7.5).days.ago) }
        let!(:log_2) { create(:route_log, trailer_id: trailer.id, sent_at: 2.days.ago) }
        let(:params) { { 'auth' => auth, 'trailer_id' => trailer.id } }

        it 'returns records logged since 7 days' do
          expect(subject).to eq [log_2]
        end
      end

      context 'with filter passed' do
        let!(:log_1) { create(:route_log, trailer: trailer, sent_at: 30.minutes.ago) }
        let!(:log_2) { create(:route_log, trailer: trailer, sent_at: 29.minutes.ago) }
        let!(:log_3) { create(:route_log, trailer: trailer, sent_at: 28.minutes.ago) }
        let!(:log_4) { create(:route_log, trailer: trailer, sent_at: 10.minutes.ago) }

        let(:params) {
          {
            'auth' => auth,
            'trailer_id' => trailer.id,
            'filter' => {
              'date_from' => log_1.sent_at.iso8601,
              'date_to' => (log_1.sent_at + 5.minutes).iso8601
            }
          }
        }

        it 'returns records filtered by date' do
          expect(subject).to eq([log_3, log_2, log_1])
        end
      end
    end

    context 'when params are not filled in' do
      let(:params) { { } }

      it 'returns proper errors' do
        expect(subject[:errors][:trailer_id]).to include(I18n.t('errors.key?'))
      end
    end

    context 'when params in incorrect format are passed' do
      context 'when id is not an integer' do
        let(:params) { { trailer_id: 'test_trailer_id' } }

        it 'returns proper errors' do
          expect(subject[:errors][:trailer_id]).to include(I18n.t('errors.int?'))
        end
      end
    end

    context 'when trailer does not exists' do
      let(:params) { { auth: auth, trailer_id: -5 } }

      it 'return proper error' do
        expect(subject).to eq 'Trailer not found'
      end
    end

    context 'when has no access permissions' do
      let(:trailer) { create(:trailer) }
      let(:params)  { { auth: auth, trailer_id: trailer.id } }

      it 'return proper error' do
        expect(subject).to eq 'Trailer not found'
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
  end
end
