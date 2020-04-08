require 'rails_helper'

RSpec.describe Api::V1::Logistician::UpdateProfile do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |logistician| logistician }
        m.failure { |res| res }
      end
    end

    let(:logistician) { create(:logistician, :with_auth, :with_person) }

    context 'with valid params' do
      let(:params) {
        attributes_for(:person, :with_base64_avatar)
          .merge(auth: logistician.auth, email: Faker::Internet.safe_email, password: 'password1234', preferred_locale: 'de')
      }

      it 'updates logistician' do
        expect(subject).to have_attributes(
          person: have_attributes(
            first_name: params[:first_name],
            last_name: params[:last_name],
            phone_number: Phony.normalize(params[:phone_number]),
            extra_phone_number: Phony.normalize(params[:extra_phone_number]),
            email: params[:email],
            avatar: be_present
          ),
          auth: have_attributes(email: params[:email]),
          preferred_locale: 'de'
        )
      end
    end

    context 'with no preferred_locale provided' do
      let(:params) {
        attributes_for(:person)
          .merge(auth: logistician.auth, email: Faker::Internet.safe_email, password: 'password1234')
      }

      it 'sets polish as default' do
        expect(subject).to have_attributes(
          preferred_locale: 'pl'
        )
      end
    end

    context 'with empty extra phone number' do
      let(:params) {
        attributes_for(:person, extra_phone_number: nil)
          .merge(auth: logistician.auth, email: Faker::Internet.safe_email, password: 'password1234')
      }

      it 'resets extra_phone_number' do
        expect(subject.person).to have_attributes(extra_phone_number: nil)
      end
    end

    context 'with invalid params' do
      let(:errors) { subject[:errors] }

      context 'with empty attributes' do
        let(:params) { { auth: nil, email: '', password: '' } }

        it 'returns errors' do
          expect(errors[:first_name]).to include(I18n.t('errors.key?'))
          expect(errors[:last_name]).to include(I18n.t('errors.key?'))
          expect(errors[:phone_number]).to include(I18n.t('errors.key?'))
          expect(errors[:auth]).to include(I18n.t('errors.filled?'))
          expect(errors[:email]).to include(I18n.t('errors.filled?'))
          expect(errors[:password]).to include(I18n.t('errors.filled?'))
          expect(errors[:extra_phone_number]).to be_nil
        end
      end

      context 'with invalid email and phone number' do
        let(:params) { { auth: logistician.auth, email: 'a@', phone_number: '555 666 777', extra_phone_number: '666-555-444' } }

        it 'returns errors' do
          expect(errors[:email]).to include(I18n.t('errors.email?'))
          expect(errors[:phone_number]).to include(I18n.t('errors.phone_number?'))
          expect(errors[:extra_phone_number]).to include(I18n.t('errors.phone_number?'))
        end
      end

      context 'with taken email' do
        let(:logistician_2) { create(:logistician, :with_auth) }
        let(:params)        { attributes_for(:logistician).merge(auth: logistician.auth, email: logistician_2.auth.email) }

        it 'returns errors' do
          expect(errors[:email]).to include(I18n.t('errors.unique?'))
        end
      end

      context 'with invalid password' do
        let(:params) {
          attributes_for(:logistician)
            .merge(auth: logistician.auth, email: Faker::Internet.safe_email, password: 'password12345')
        }

        it 'returns errors' do
          expect(errors[:password]).to include(I18n.t('errors.valid_password?'))
        end
      end

      context 'with invalid preferred_locale' do
        let(:params) {
          attributes_for(:logistician)
            .merge(preferred_locale: "non-existing")
        }
        it 'returns error' do
          expect(errors).to include(:preferred_locale)
        end
      end
    end
  end
end
