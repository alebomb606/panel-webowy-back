require 'rails_helper'

RSpec.describe TrailerPresenter do

  describe 'methods' do
    let!(:trailer)  { create(:trailer) }
    let(:presenter) { TrailerPresenter.new(trailer) }

    describe '#access_permission_id' do
      let!(:logistician) { create(:logistician, trailers: [trailer]) }

      it 'returns access permission id' do
        expect(presenter.access_permission_id(logistician: logistician)).to eq trailer.access_permissions.find_by(logistician_id: logistician.id).id
      end
    end

    describe '#company' do
      it 'returns company name' do
        expect(presenter.company).to eq trailer.company.name
      end
    end
  end
end
