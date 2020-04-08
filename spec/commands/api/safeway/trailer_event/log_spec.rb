require 'rails_helper'

RSpec.describe Api::Safeway::TrailerEvent::Log do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success {}
        m.failure { |res| res }
      end
    end

    let(:trailer) { create(:trailer) }

    context 'with valid params' do
      let(:params) {
        attributes_for(:trailer_event).merge(
          trailer: trailer
        )
      }

      it 'creates new trailer_event record' do
        expect { subject }.to change { ::TrailerEvent.count }.by(1)
      end

      it 'creates trailer_event' do
        subject
        expect(::TrailerEvent.last).to have_attributes(
          kind: params[:kind],
          triggered_at: params[:triggered_at],
          sensor_name: params[:sensor_name]
        )
      end
    end

    context 'with empty attributes' do
      let(:params)  {
        attributes_for(:trailer_event,
          kind: '',
          triggered_at: '',
          latitude: '',
          longitude: '',
          uuid: ''
        ).merge(trailer: trailer)
      }
      let(:errors)  { subject[:errors] }

      it 'does not create new trailer_event record' do
        expect { subject }.not_to change { ::TrailerEvent.count }
      end

      it 'returns errors' do
        expect(errors).to include(:kind, :triggered_at)
        expect(errors[:triggered_at]).to include(I18n.t('errors.filled?'))
        expect(errors[:kind]).to include(I18n.t('errors.filled?'))
        expect(errors[:uuid]).to include(I18n.t('errors.filled?'))
      end
    end

    context 'with invalid kind selected' do
      let(:params) { attributes_for(:trailer_event, trailer: trailer, kind: :xyzabc) }
      let(:errors) { subject[:errors] }

      it 'returns error' do
        expect(errors[:kind]).to include(I18n.t('errors.included_in?.arg.default', list: ::TrailerEvent.kinds.keys.join(', ')))
      end
    end
  end
end
