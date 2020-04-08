require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let!(:auth) { create(:auth, :with_logistician) }

  describe '.connect' do
    context 'for frontend connection' do
      context 'with valid params' do
        let(:channel_uuid) { '12345' }

        before do
          allow(SecureRandom).to receive(:uuid).and_return(channel_uuid)
          connect '/cable', params: { connection_type: 'frontend' }.merge(auth.create_new_auth_token)
        end

        it 'connects succesfully' do
          expect(connection.current_auth).to eq(auth)
        end
      end

      context 'with invalid auth params' do
        it 'rejects connection' do
          expect { connect '/cable', params: { connection_type: 'frontend' } }.to have_rejected_connection
        end
      end
    end

    context 'for banana connection' do
      context 'with valid params' do
        let(:trailer) { create(:trailer) }

        before do
          connect '/cable', params: { token: trailer.banana_pi_token }
        end

        it 'connects succesfully' do
          expect(connection.current_trailer).to eq(trailer)
        end
      end

      context 'with invalid params' do
        it 'rejects connection' do
          expect { connect '/cable', params: { token: 'qwerty' } }.to have_rejected_connection
        end
      end
    end
  end
end