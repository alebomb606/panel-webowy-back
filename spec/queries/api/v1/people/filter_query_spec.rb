require 'rails_helper'

RSpec.describe Api::V1::People::FilterQuery do
  describe '#call' do
    subject do
      described_class.new.call(params) do |r|
        r.success { |res| res }
        r.failure { |res| res }
      end
    end

    context 'with filter param passed' do
      let(:auth) { create(:auth, logistician: logistician) }

      context 'with keyword matching phone number' do
        let(:logistician)  { create(:logistician) }
        let!(:person)      { create(:person, personifiable: logistician, phone_number: '+48515151515', extra_phone_number: nil) }
        let(:params)       { { 'filter' => { 'keyword' => '5151' }, 'auth' => auth } }

        it 'returns matching person' do
          expect(subject).to eq([person])
        end
      end

      context 'with keyword matching first name and email' do
        let(:logistician)  { create(:logistician) }
        let!(:person)      { create(:person, first_name: 'John', personifiable: logistician) }
        let(:params)       { { 'filter' => { 'keyword' => 'joh' }, 'auth' => auth } }

        context 'with person in the same company' do
          let(:logistician_2) { create(:logistician) }
          let!(:person_2)     { create(:person, personifiable: logistician_2, company: logistician.person.company, first_name: 'Larry', email: 'johny@example.com') }

          it 'returns matching logisticians' do
            expect(subject).to match_array([person, person_2])
          end
        end

        context 'with people in the different companies' do
          let!(:logistician_2) { create(:logistician) }
          let!(:person_2)      { create(:person, personifiable: logistician_2, first_name: 'Larry', last_name: 'Johnson') }

          it 'returns person from the searched company' do
            expect(subject).to eq([person])
          end
        end
      end
    end

    context 'without filter param passed' do
      let(:params)  { { 'auth' => Auth.first } }
      let(:company) { create(:company) }

      before do
        2.times { create(:person, personifiable: create(:logistician, :with_auth), company: company) }
      end

      it 'returns all the people from the company' do
        expect(subject).to match_array(company.people)
      end
    end
  end
end
