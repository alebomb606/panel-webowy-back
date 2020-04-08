require 'rails_helper'

RSpec.describe MasterAdmin::Trailer::UpdatePlan do
  describe '#call' do
    subject do
      described_class.new.call(trailer, params) do |m|
        m.success {}
        m.failure { |res| res }
      end
    end

    let(:trailer) { create(:trailer, :with_plan) }
    let(:plan) do
      subject
      trailer.plan.reload
    end

    context 'with valid params' do
      context 'with features passed as symbols' do
        let(:params) { attributes_for(:plan, kind: 'premium', selected_features: ::Plan.features_for('premium').map(&:to_sym)) }

        it 'updates plan with passed params' do
          expect(plan.selected_features).to match_array(params[:selected_features])
          expect(plan.kind).to eq(params[:kind])
        end
      end

      context 'with features passed as strings' do
        let(:params) { attributes_for(:plan, kind: 'expanded', selected_features: ::Plan.features_for('expanded')) }

        it 'updates plan with passed params' do
          expect(plan.selected_features).to match_array(params[:selected_features].map(&:to_sym))
          expect(plan.kind).to eq(params[:kind])
        end
      end

      context 'with features not valid for specific plan kind' do
        let(:params) { attributes_for(:plan, kind: 'fundamental', selected_features: %i[event_log]) }

        it 'updates plan with passed params and sets kind to custom' do
          expect(plan.selected_features).to match_array(params[:selected_features])
          expect(plan.kind).to eq('custom')
        end
      end

      context 'with features valid for other kind but not for selected' do
        let(:params) { attributes_for(:plan, kind: 'premium', selected_features: ::Plan.features_for('fundamental')) }

        it 'creates plan with resolved kind' do
          expect(plan.selected_features).to match_array(params[:selected_features].map(&:to_sym))
          expect(plan.kind).to eq('fundamental')
        end
      end
    end

    context 'with invalid params' do
      context 'with features not being an array' do
        let(:params) { { kind: 1234, selected_features: 12345 } }
        let(:errors) { subject[:errors] }

        it 'returns errors' do
          expect(errors[:selected_features]).to include(I18n.t('errors.array?'))
          expect(errors[:kind]).to include(I18n.t('errors.str?'))
        end
      end

      context 'with few features that are invalid' do
        let(:params)             { attributes_for(:plan, kind: 'custom', selected_features: %i[a b top_left_camera]) }
        let(:errors)             { subject[:errors][:selected_features] }
        let(:available_features) { Plan.new.all_features.join(', ') }

        it 'returns errors' do
          expect(errors[0]).to include(I18n.t('errors.included_in?.arg.default', list: available_features))
          expect(errors[1]).to include(I18n.t('errors.included_in?.arg.default', list: available_features))
          expect(errors[2]).to be_nil
        end
      end

      context 'with invalid kind' do
        let(:params) { attributes_for(:plan, kind: 'abcdef', trailer_id: trailer.id) }

        it 'returns errors' do
          expect(subject[:errors][:kind]).to include(I18n.t('errors.included_in?.arg.default', list: ::Plan.kinds.keys.join(', ')))
        end
      end
    end
  end
end
