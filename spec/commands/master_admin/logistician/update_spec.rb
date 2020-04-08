require 'rails_helper'

RSpec.describe MasterAdmin::Logistician::Update do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |log| log }
        m.failure(:company_not_found) { 'company not found' }
        m.failure(:logistician_not_found) { 'logistician not found' }
        m.failure { |res| res }
      end
    end

    let!(:auth)       { create(:auth, logistician: logistician) }
    let!(:company)    { create(:company) }
    let(:logistician) { create(:logistician) }
    let!(:person)     { create(:person, personifiable: logistician, company: company) }
    let(:attributes)  { person.attributes.symbolize_keys.merge(company_id: company.id) }

    context 'with valid params' do
      let(:params) { { person_attributes: attributes.merge(first_name: 'Pudzian'), id: logistician.id } }

      it 'updates logisitican\'s name' do
        expect(subject.person.reload.first_name).to eq('Pudzian')
      end
    end

    context 'when company is not found' do
      let(:params) { { person_attributes: attributes.merge(company_id: -1), id: logistician.id } }

      it 'stops process at finding company' do
        expect(subject).to eq 'company not found'
      end
    end

    context 'when company is archived' do
      let(:company) { create(:company, :archived) }
      let(:params)  { { person_attributes: attributes.merge(company_id: company.id), id: logistician.id } }

      it 'stops process at finding company' do
        expect(subject).to eq 'company not found'
      end
    end

    context 'when logisitician is not found' do
      let(:params) { { person_attributes: attributes, id: -1 } }

      it 'stops process at finding logistician' do
        expect(subject).to eq 'logistician not found'
      end
    end

    context 'when logistician is archived' do
      let(:logistician) { create(:logistician, :archived) }
      let(:params)      { { person_attributes: attributes, id: logistician.id } }

      it 'stops process at finding logistician' do
        expect(subject).to eq 'logistician not found'
      end
    end

    context 'with invalid params' do
      let(:params) { { person_attributes: { email: 'dadasd' }, id: logistician.id } }
      let(:errors) { subject[:errors] }

      it 'does not update logistician\'s email' do
        expect { subject }.not_to change { logistician.auth.reload.email }
      end

      it 'returns errors' do
        expect(errors[:person_attributes]).to include(:first_name, :last_name, :phone_number, :email)
        expect(errors[:person_attributes][:email]).to include(I18n.t('errors.email?'))
      end
    end
  end
end
