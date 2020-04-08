require 'rails_helper'

RSpec.describe MasterAdmin::Driver::Create do
  describe '#call' do
    subject {
      described_class.new.call(params) do |m|
        m.success { |log| log }
        m.failure(:company_not_found) { 'company not found' }
        m.failure { |res| res }
      end
    }

    let(:company) { create(:company) }

    context 'with valid params' do
      let(:params) { { person_attributes: attributes_for(:person, company_id: company.id) } }

      it 'creates person' do
        expect { subject }.to change { ::Person.count }.by(1)
      end

      it 'creates person with passed params' do
        expect(subject.person).to have_attributes(params[:person_attributes])
      end
    end

    let(:errors) { subject[:errors] }

    context 'with invalid params' do
      let(:params) { { person_attributes: { email: 'abc' } } }

      it 'does not create person' do
        expect { subject }.not_to change { ::Person.count }
      end

      it 'returns errors' do
        expect(errors[:person_attributes]).to include(:first_name, :last_name, :email, :phone_number)
        expect(errors[:person_attributes][:email]).to include(I18n.t('errors.email?'))
      end
    end

    context 'when company is archived' do
      let(:company) { create(:company, :archived) }
      let(:params)  { { person_attributes: attributes_for(:person, company_id: company.id) } }

      it 'returns not found' do
        expect(subject).to eq('company not found')
      end
    end

    context 'with non-unique email' do
      let(:driver) { create(:driver) }
      let(:params) { { person_attributes: attributes_for(:person, company_id: company.id, email: driver.person.email ) } }

      it 'returns error' do
        expect(errors[:person_attributes][:email]).to include(I18n.t('errors.unique?'))
      end
    end

    context 'with non-existing company' do
      let(:params) { { person_attributes: attributes_for(:person, company_id: -1) } }

      it 'does not create person' do
        expect { subject }.not_to change { ::Person.count }
      end

      it 'returns not found' do
        expect(subject).to eq('company not found')
      end
    end
  end
end
