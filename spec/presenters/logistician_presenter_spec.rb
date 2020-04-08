require 'rails_helper'

RSpec.describe LogisticianPresenter do
  let!(:auth) { create(:auth, email: 'sample@sample.com', logistician: logistician) }
  let!(:logistician) { create(:logistician) }
  let!(:person) { create(:person, first_name: 'Firstname', last_name: 'Lastname', personifiable: logistician) }

  describe 'methods' do
    let(:presenter) { LogisticianPresenter.new(logistician) }

    describe '#full_name' do
      it 'returns logisticians full name' do
        expect(presenter.full_name).to eq 'Firstname Lastname'
      end
    end

    describe '#id' do
      it 'returns logisticians id' do
        expect(presenter.id).to eq logistician.id
      end
    end

    describe '#company' do
      it 'returns company name' do
        expect(presenter.company).to eq person.company.name
      end
    end

    describe '#email' do
      it 'returns auth email' do
        expect(presenter.email).to eq 'sample@sample.com'
      end
    end
  end
end
