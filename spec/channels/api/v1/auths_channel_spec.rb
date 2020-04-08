require 'rails_helper'

RSpec.describe Api::V1::AuthsChannel, type: :channel do
  let(:auth) { create(:auth, :with_logistician) }

  describe '.subscribe' do
    before do
      stub_connection(current_auth: auth)
      subscribe
    end

    it 'subscribes correctly' do
      expect(subscription).to be_confirmed
    end

    it 'has valid stream' do
      expect(subscription).to have_stream_from("auths_#{auth.id}")
    end
  end
end
