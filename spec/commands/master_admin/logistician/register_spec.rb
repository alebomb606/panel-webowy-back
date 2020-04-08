require 'rails_helper'

RSpec.describe MasterAdmin::Logistician::Register do
  describe '#call' do
    subject {
      described_class.new.call(params) do |m|
        m.success { |log| log }
        m.failure(:not_found) { 'not found' }
        m.failure { |res| res }
      end
    }

    let(:company) { create(:company) }

    context 'with valid params' do
      let(:params)  { { person_attributes: attributes_for(:person, company_id: company.id), preferred_locale: 'pl' } }

      it 'creates new Logistician record' do
        expect { subject }.to change { ::Logistician.count }.by(1)
      end

      it 'creates new Auth record' do
        expect { subject }.to change { ::Auth.count }.by(1)
      end

      it 'creates Logistician with passed params' do
        expect(subject.person).to have_attributes(
          first_name: params[:person_attributes][:first_name],
          last_name: params[:person_attributes][:last_name],
          phone_number: params[:person_attributes][:phone_number]
        )
      end

      it 'creates Auth with Logistician\'s email' do
        expect(subject.auth).to have_attributes(
          email: params[:person_attributes][:email]
        )
      end
    end

    context 'with invalid params' do
      let(:params)  { { person_attributes: { email: 'abc' }, preferred_locale: 'non-existing' } }
      let(:errors) { subject[:errors] }

      it 'does not create Logistician record' do
        expect { subject }.not_to change { ::Logistician.count }
      end

      it 'does not create Auth record' do
        expect { subject }.not_to change { ::Auth.count }
      end

      it 'returns errors' do
        expect(errors[:person_attributes]).to include(:first_name, :last_name, :email, :phone_number)
        expect(errors[:person_attributes][:email]).to include(I18n.t('errors.email?'))
      end
    end

    context 'when company is archived' do
      let(:company) { create(:company, :archived) }
      let(:params)  { { person_attributes: attributes_for(:person, company_id: company.id), preferred_locale: 'pl' } }

      it 'returns record not found' do
        expect(subject).to eq('not found')
      end
    end

    context 'with non-existing company' do
      let(:params)  { { person_attributes: attributes_for(:person, company_id: -1), preferred_locale: 'pl' } }

      it 'does not create Logistician record' do
        expect { subject }.not_to change { ::Logistician.count }
      end

      it 'does not create Auth record' do
        expect { subject }.not_to change { ::Auth.count }
      end

      it 'returns not found' do
        expect(subject).to eq('not found')
      end
    end
  end
end
