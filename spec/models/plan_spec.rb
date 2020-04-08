require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe '.features_for' do
    context 'with premium kind' do
      let(:features) { ::Plan.new.all_features.map(&:to_s) }

      it 'returns premium features' do
        expect(::Plan.features_for('premium')).to match_array(features)
      end
    end

    context 'with unknown kind' do
      it 'returns empty array' do
        expect(::Plan.features_for('abcdef')).to be_empty
      end
    end
  end

  describe '.kind_for' do
    context 'with empty features' do
      it 'returns custom as default' do
        expect(::Plan.kind_for([])).to eq('custom')
      end
    end

    context 'with features for specific kinds' do
      it 'returns fundamental for fundamental features' do
        expect(::Plan.kind_for(::Plan::FUNDAMENTAL_FEATURES)).to eq('fundamental')
      end

      it 'returns kind for specific level' do
        features = ::Plan::FUNDAMENTAL_FEATURES
        ::Plan::FEATURE_SETS.each do |fs|
          features += fs[:features]
          expect(::Plan.kind_for(features)).to eq(::Plan.kinds.key(fs[:level]))
        end
      end
    end
  end
end
