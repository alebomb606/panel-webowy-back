require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'scopes' do
    describe '::active' do
      let!(:company) { create(:company) }
      let!(:archived_company) { create(:company, :archived) }

      it 'returns only archived records' do
        expect(Company.active).to eq [company]
      end
    end
  end
end
