require 'rails_helper'

RSpec.describe MasterAdmin::Company::Register do
  describe '#call' do
    subject {
      described_class.new.call(params) do |m|
        m.success {}
        m.failure { |res| res }
      end
    }

    context 'with valid params' do
      let(:params)  { attributes_for(:company) }

      it 'creates new company record' do
        expect { subject }.to change { ::Company.count }.by(1)
      end

      it 'creates company' do
        subject
        expect(::Company.last).to have_attributes(
          name: params[:name],
          email: params[:email],
          nip: params[:nip]
        )
      end
    end

    context 'when nip is entered with dashes' do
      let(:params)  { attributes_for(:company, nip: '0000-0000-00') }

      it 'creates a company' do
        expect{ subject }.to change{ Company.count }.by 1
      end

      it 'strips the nip from extra dashes' do
        subject
        expect(Company.last.nip).to eq '0' * 10
      end
    end

    context 'with valid attributes when company with the same name is archived' do
      let!(:company) { create(:company, :archived) }
      let(:params) { attributes_for(:company, name: company.name) }

      it 'creates new company' do
        expect{ subject }.to change{ Company.count }.by 1
      end
    end

    context 'with invalid params' do
      let(:params)  { { email: 'a', nip: '1234' } }
      let(:errors)  { subject[:errors] }

      it 'does not create new company record' do
        expect { subject }.not_to change { ::Company.count }
    end

      it 'returns errors' do
        expect(errors).to include(:email, :nip, :city, :street, :postal_code, :name)
        expect(errors[:email]).to include(I18n.t('errors.email?'))
        expect(errors[:nip]).to include(I18n.t('errors.format?'))
      end
    end

    context 'when nip is invalid format' do
      let(:params)  { { nip: 'ABCDEF1234' } }
      let(:errors)  { subject[:errors] }

      it 'does not create new company record' do
        expect { subject }.not_to change { ::Company.count }
      end

      it 'returns errors' do
        expect(subject[:errors][:nip]).to include(I18n.t('errors.format?'))
      end
    end

    context 'with attributes that are not unique' do
      let!(:company) { create(:company) }
      let(:params)   { company.attributes }
      let(:errors)   { subject[:errors] }

      it 'does not create new company record' do
        expect { subject }.not_to change { ::Company.count }
      end

      it 'returns errors' do
        expect(errors[:email]).to include(I18n.t('errors.unique?'))
        expect(errors[:nip]).to include(I18n.t('errors.unique?'))
        expect(errors[:name]).to include(I18n.t('errors.unique?'))
      end
    end
  end
end
