require 'rails_helper'

RSpec.describe CompanyPresenter do
  let(:company) { create(:company, city: 'city', postal_code: '12345', street: 'street') }

  describe 'methods' do
    let(:presenter) { CompanyPresenter.new(company) }

    describe '#address' do
      it 'returns properly formatted address' do
        expect(presenter.address).to eq 'street, 12345 city'
      end
    end
  end
end
