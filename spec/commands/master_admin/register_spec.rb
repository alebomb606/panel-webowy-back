require 'rails_helper'

RSpec.describe MasterAdmin::Register do
  describe '#call' do
    subject {
      described_class.new.call(params) do |m|
        m.success {}
        m.failure { |res| res }
      end
    }

    context 'with valid params' do
      let(:params)  { attributes_for(:master_admin).merge(email: 'email@example.com') }

      it 'creates new MasterAdmin record' do
        expect { subject }.to change { ::MasterAdmin.count }.by(1)
      end

      it 'creates new Auth record' do
        expect { subject }.to change { ::Auth.count }.by(1)
      end

      it 'creates MasterAdmin with passed params' do
        subject
        expect(::MasterAdmin.last).to have_attributes(
          first_name: params[:first_name],
          last_name: params[:last_name],
          phone_number: params[:phone_number]
        )
      end

      it 'creates Auth with MasterAdmin\'s email' do
        subject
        expect(::Auth.last).to have_attributes(
          email: params[:email]
        )
      end
    end

    context 'with invalid params' do
      let(:params) { { email: 'abc' } }
      let(:errors) { subject[:errors] }

      it 'does not create MasterAdmin record' do
        expect { subject }.not_to change { ::MasterAdmin.count }
      end

      it 'does not create Auth record' do
        expect { subject }.not_to change { ::Auth.count }
      end

      it 'returns errors' do
        expect(errors).to include(:first_name, :last_name, :email)
        expect(errors[:email]).to include(I18n.t('errors.email?'))
      end
    end
  end
end
