FactoryBot.define do
  factory :plan do
    kind              { ::Plan.kinds.keys.sample }
    selected_features { ::Plan.features_for(kind) }
  end
end
