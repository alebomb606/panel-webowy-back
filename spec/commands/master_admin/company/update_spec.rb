require 'rails_helper'

RSpec.describe MasterAdmin::Company::Update do
  subject do
    described_class.new.call(params) do |m|
      m.success {}
      m.failure(:company_not_found) { 'Company not found' }
      m.failure { |res| res }
    end
  end

  context 'when attributes are not filled in' do
    let(:company) { create(:company) }
    let(:params) { { id: company.id, name: '', street: '', city: '', postal_code: '', nip: '', email: '' } }
    let(:errors) { subject[:errors] }

    it 'returns proper errors' do
      expect(errors[:name]).to include(I18n.t('errors.filled?'))
      expect(errors[:email]).to include(I18n.t('errors.filled?'))
      expect(errors[:nip]).to include(I18n.t('errors.filled?'))
      expect(errors[:postal_code]).to include(I18n.t('errors.filled?'))
      expect(errors[:street]).to include(I18n.t('errors.filled?'))
      expect(errors[:city]).to include(I18n.t('errors.filled?'))
    end
  end

  context 'when invalid params are passed' do
    let(:company) { create(:company) }
    let(:params) { company.attributes.symbolize_keys.merge(nip: 'a' * 11) }

    context 'when name is not unique' do
      let(:company) { create(:company) }
      let!(:second_company) { create(:company) }
      let(:params) { company.attributes.symbolize_keys.merge(name: second_company.name) }

      it 'returns an error' do
        expect(subject[:errors][:name]).to include(I18n.t('errors.unique?'))
      end
    end

    context 'when email is not unique' do
      let(:company) { create(:company) }
      let!(:second_company) { create(:company) }
      let(:params) { company.attributes.symbolize_keys.merge(email: second_company.email) }

      it 'returns an error' do
        expect(subject[:errors][:email]).to include(I18n.t('errors.unique?'))
      end
    end

    context 'when nip is not 10 characters long' do
      let(:company) { create(:company) }
      let(:params) { company.attributes.symbolize_keys.merge(nip: '1' * 11) }

      it 'returns an error' do
        expect(subject[:errors][:nip]).to include(I18n.t('errors.format?'))
      end
    end

    context 'when nip is in invalid format' do
      let(:company) { create(:company) }
      let(:params) { company.attributes.symbolize_keys.merge(nip: 'abcdef1234') }

      it 'returns an error' do
        expect(subject[:errors][:nip]).to include(I18n.t('errors.format?'))
      end
    end
  end

  context 'when nip is entered with dashes' do
    let(:company) { create(:company) }
    let(:params) { company.attributes.symbolize_keys.merge(nip: '0000-0000-00') }

    it 'updates company\'s nip' do
      subject
      expect(company.reload.nip).to eq '0' * 10
    end
  end

  context 'when valid params are passed' do
    let(:company) { create(:company) }
    let(:params) { company.attributes.symbolize_keys.merge(name: 'updatedCompanyName') }

    it 'updates company\'s name' do
      subject
      expect(company.reload.name).to eq 'updatedCompanyName'
    end
  end

  context 'when company with the same name is archived' do
    let!(:other_company) { create(:company, :archived) }
    let!(:company) { create(:company) }
    let(:params) { company.attributes.symbolize_keys.merge(name: other_company.name) }

    it 'updates company\'s name' do
      subject
      expect(company.reload.name).to eq other_company.name
    end
  end

  context 'when company is not found' do
    let(:params) { { id: -5 } }

    it 'stops at finding company step' do
      expect(subject).to eq 'Company not found'
    end
  end

  context 'when company is archived' do
    let(:company) { create(:company, :archived) }
    let(:params) { { id: company.id } }

    it 'stops at finding company step' do
      expect(subject).to eq 'Company not found'
    end
  end
end
