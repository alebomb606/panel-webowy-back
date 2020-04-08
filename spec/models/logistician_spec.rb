require 'rails_helper'

RSpec.describe Logistician, type: :model do
  describe 'scopes' do
    describe '::active' do
      let!(:logistician) { create(:logistician) }
      let!(:archived_logistician) { create(:logistician, :archived) }

      it 'returns active logisticians' do
        expect(Logistician.active).to eq [logistician]
      end
    end
  end
end
