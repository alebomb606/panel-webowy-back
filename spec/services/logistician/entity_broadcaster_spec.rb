require 'rails_helper'

RSpec.describe Auth::EntityBroadcaster do
  let(:auth) { create(:auth) }

  subject { described_class.new(entities: entities, auth: auth, serializer: serializer).call }

  describe '#call' do
    context 'with object not wrapped in an array' do
      let(:entities)   { create(:trailer_event) }
      let(:serializer) { ::TrailerEventSerializer }
      let(:serialized) {
        {
          data: [
            {
              id: entities.id.to_s,
              type: 'trailer_event',
              attributes: {}
            }
          ]
        }
      }

      it 'broadcasts wrapped serialized data' do
        expect { subject }.to have_broadcasted_to("auths_#{auth.id}")
          .with(include_json(serialized)).once
      end
    end

    context 'with empty collection' do
      let(:entities)   { [] }
      let(:serializer) { nil }

      it 'does not send any data' do
        expect { subject }.not_to have_broadcasted_to("auths_#{auth.id}")
      end
    end
  end
end
