require 'rails_helper'

RSpec.describe Api::V1::Logistician::UpdatePassword do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |logistician| logistician }
        m.failure { |res| res }
      end
    end

    let(:logistician) { create(:logistician, :with_auth) }

    context 'with valid params' do
      let(:params) {
        {
          auth: logistician.auth,
          current_password: 'password1234',
          password: 'abc1234',
          password_confirmation: 'abc1234'
        }
      }

      it 'updates password' do
        expect { subject }.to change { logistician.auth.password }
      end
    end

    context 'with invalid params' do
      let(:errors) { subject[:errors] }

      context 'with empty attributes' do
        let(:params) { { auth: nil, password: '' } }

        it 'returns errors' do
          expect(errors[:auth]).to include(I18n.t('errors.filled?'))
          expect(errors[:current_password]).to include(I18n.t('errors.key?'))
          expect(errors[:password]).to include(I18n.t('errors.filled?'))
        end
      end

      context 'with invalid current password' do
        let(:params) {
          {
            auth: logistician.auth,
            current_password: 'password12345',
            password: 'password1234567',
            password_confirmation: 'password1234567'
          }
        }

        it 'returns errors' do
          expect(errors[:current_password]).to include(I18n.t('errors.valid_password?'))
        end
      end

      context 'with invalid confirmation' do
        let(:params) {
          {
            auth: logistician.auth,
            current_password: 'password1234',
            password: 'password1234567',
            password_confirmation: 'password12345678'
          }
        }

        it 'returns errors' do
          expect(errors[:password_confirmation]).to include(I18n.t('errors.eql?', left: params[:password]))
        end
      end

      context 'with invalid pass length' do
        let(:params) {
          {
            auth: logistician.auth,
            current_password: 'password1234',
            password: 'p1',
            password_confirmation: 'p1'
          }
        }

        let(:pass_len) { Devise.password_length }

        it 'returns errors' do
          expect(errors[:password]).to include(
            I18n.t('errors.size?.value.string.arg.range',
              size_left: pass_len.min,
              size_right: pass_len.max
            )
          )
        end
      end
    end
  end
end
