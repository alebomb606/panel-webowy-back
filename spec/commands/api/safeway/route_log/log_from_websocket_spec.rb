require 'rails_helper'

RSpec.describe Api::Safeway::RouteLog::LogFromWebsocket do
  describe '#call' do
    subject do
      described_class.new.call(trailer, params) do |m|
        m.success { |res| res }
        m.failure { |res| res }
      end
    end

    let!(:trailer) { create(:trailer) }
    let(:base_params) {
      {
        latitude: Faker::Address.latitude, longitude: Faker::Address.longitude, speed: Faker::Number.digit
      }
    }

    context 'with valid params' do
      let(:params) { base_params.merge(sent_at: Time.current.iso8601, timestamp: Time.now.utc.to_i) }

      it 'creates new route log record' do
        expect { subject }.to change { ::RouteLog.count }.by(1)
      end

      it 'saves route log attributes' do
        expect(subject).to have_attributes(
          latitude: BigDecimal(params[:latitude].to_s).round(6),
          longitude: BigDecimal(params[:longitude].to_s).round(6),
          sent_at: Time.iso8601(params[:sent_at]),
          timestamp: (params[:timestamp]).to_f.round(1),
          speed: BigDecimal(params[:speed].to_s)
        )
      end
    end

    context 'with no sent_at passed' do
      let(:params) { base_params.merge( timestamp: Time.now.utc.to_i ) }
      let(:now)    { Time.now.change(:usec => 0) }

      before do
        allow(Time).to receive(:current).and_return(now)
      end

      it 'creates new route log record' do
        expect { subject }.to change { ::RouteLog.count }.by(1)
      end

      it 'saves route log with current time as sent_at' do
        expect(subject).to have_attributes(
          latitude: BigDecimal(params[:latitude].to_s).round(6),
          longitude: BigDecimal(params[:longitude].to_s).round(6),
          sent_at: now,
          timestamp: Time.now.to_i.to_f.round(1),
          speed: BigDecimal(params[:speed].to_s)
        )
      end
    end

    let(:errors) { subject[:errors] }

    context 'with empty attributes' do
      let(:params) { { latitude: nil, longitude: nil, speed: nil } }

      it 'does not create new route log record' do
        expect { subject }.not_to change { ::RouteLog.count }
      end

      it 'returns errors' do
        expect(errors[:latitude]).to include(I18n.t('errors.filled?'))
        expect(errors[:longitude]).to include(I18n.t('errors.filled?'))
        expect(errors[:speed]).to include(I18n.t('errors.filled?'))
      end
    end

    context 'when latitude and longitude are not decimals' do
      let(:params) { { latitude: 'a', longitude: 'b'} }

      it 'does not create new route log record' do
        expect { subject }.not_to change { ::RouteLog.count }
      end

      it 'returns errors' do
        expect(errors[:latitude]).to include(I18n.t('errors.decimal?'))
        expect(errors[:longitude]).to include(I18n.t('errors.decimal?'))
      end
    end

    context 'with invalid latitude and longitude' do
      let(:params) { { latitude: -1000, longitude: 10000, speed: -20} }

      it 'returns proper errors' do
        expect(errors[:longitude]).to include(I18n.t('errors.longitude?'))
        expect(errors[:latitude]).to include(I18n.t('errors.latitude?'))
        expect(errors[:speed]).to include(I18n.t('errors.speed?'))
      end
    end
  end
end
