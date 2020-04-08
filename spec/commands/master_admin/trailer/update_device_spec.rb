require 'rails_helper'

RSpec.describe MasterAdmin::Trailer::UpdateDevice do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success {}
        m.failure(:company_not_found) { 'Company not found' }
        m.failure(:trailer_not_found) { 'Trailer not found' }
        m.failure { |res| res }
      end
    end

    let(:company)  { create(:company) }
    let(:trailer)  { create(:trailer, company: company) }
    let!(:plan)    { create(:plan, selected_features: [], trailer: trailer) }

    context 'whe invalid params are passed' do
      context 'with invalid plan features' do
        let(:params)  {
          attributes_for(:trailer)
            .merge(plan_attributes: { selected_features: [1, 2, 3] })
            .merge(id: trailer.id, company_id: company.id)
        }

        it 'does not update trailer' do
          expect { subject }.not_to change { trailer.reload.attributes }
        end

        it 'does not update plan' do
          expect { subject }.not_to change { trailer.reload.plan.attributes }
        end
      end

      context 'with no plan features' do
        let(:params)  {
          attributes_for(:trailer)
            .merge(plan_attributes: { selected_features: [] })
            .merge(id: trailer.id, company_id: company.id)
        }

        it 'does not update trailer' do
          expect { subject }.not_to change { trailer.reload.attributes }
        end

        it 'does not update plan' do
          expect { subject }.not_to change { trailer.plan.reload.attributes }
        end
      end

      context 'when device serial number is not unique' do
        let(:trailer_2) { create(:trailer, :with_plan) }
        let(:params) { trailer.attributes.symbolize_keys.merge(device_serial_number: trailer_2.device_serial_number) }

        it 'returns an error' do
          expect(subject[:errors][:device_serial_number]).to include(I18n.t('errors.unique?'))
        end
      end

      context 'when registration number is not unique' do
        let(:trailer_2) { create(:trailer, :with_plan) }
        let(:params) { trailer.attributes.symbolize_keys.merge(registration_number: trailer_2.registration_number) }

        it 'returns an error' do
          expect(subject[:errors][:registration_number]).to include(I18n.t('errors.unique?'))
        end
      end

      context 'when phone number is not unique' do
        let(:trailer_2) { create(:trailer, :with_plan) }
        let(:params) { trailer.attributes.symbolize_keys.merge(phone_number: trailer_2.phone_number) }

        it 'returns an error' do
          expect(subject[:errors][:phone_number]).to include(I18n.t('errors.unique?'))
        end
      end

      context 'when banana pi token is not unique' do
        let(:trailer_2) { create(:trailer, :with_plan) }
        let(:params) { trailer.attributes.symbolize_keys.merge(banana_pi_token: trailer_2.banana_pi_token) }

        it 'returns an error' do
          expect(subject[:errors][:banana_pi_token]).to include(I18n.t('errors.unique?'))
        end
      end

      context 'when make is not expected' do
        let(:params) { trailer.attributes.symbolize_keys.merge(make: 'test') }

        it 'returns an error' do
          expect(subject[:errors][:make]).to include(I18n.t('errors.included_in?.arg.default', list: ::Trailer::MAKES.keys.join(', ')))
        end
      end

      context 'when device serial number does not match REGEXP' do
        let(:params) { trailer.attributes.symbolize_keys.merge(device_serial_number: 'test_device_serial_number') }

        it 'returns an error' do
          expect(subject[:errors][:device_serial_number]).to include(I18n.t('errors.format?'))
        end
      end
    end

    context 'when attributes are not filled in' do
      let(:params) { { id: trailer.id, company_id: company.id } }
      let(:errors) { subject[:errors] }

      it 'returns proper errors' do
        expect(errors[:device_serial_number]).to include(I18n.t('errors.key?'))
        expect(errors[:registration_number]).to include(I18n.t('errors.key?'))
        expect(errors[:device_installed_at]).to include(I18n.t('errors.key?'))
        expect(errors[:make]).to include(I18n.t('errors.key?'))
        expect(errors[:model]).to include(I18n.t('errors.key?'))
        expect(errors[:banana_pi_token]).to include(I18n.t('errors.key?'))
      end
    end

    context 'when valid params are passed' do
      let(:params) { trailer.attributes.symbolize_keys.merge(description: 'updatedTestDescription', plan_attributes: attributes_for(:plan)) }

      it 'updates device\'s description' do
        subject
        expect(trailer.reload.description).to eq 'updatedTestDescription'
      end

      it 'updates plan' do
        subject
        expect(trailer.plan.reload.kind).to eq(params[:plan_attributes][:kind])
        expect(trailer.plan.reload.selected_features.map(&:to_s)).to match_array(params[:plan_attributes][:selected_features])
      end
    end

    context 'when trailer does not exist' do
      let(:params) { { id: -5 } }

      it 'stops proceeding at finding trailer step' do
        expect(subject).to eq 'Trailer not found'
      end
    end

    context 'when trailer is archived' do
      let(:trailer) { create(:trailer, :archived) }
      let(:params)  { { id: trailer.id, company_id: company.id } }

      it 'stops proceeding at finding company step' do
        expect(subject).to eq 'Trailer not found'
      end
    end

    context 'when company is archived' do
      let!(:company) { create(:company, :archived) }
      let(:params)   { { id: trailer.id, company_id: company.id } }

      it 'stops proceeding at finding company step' do
        expect(subject).to eq 'Company not found'
      end
    end

    context 'when company does not exist' do
      let(:params) { { id: trailer.id, company_id: -5 } }

      it 'stops proceeding at finding company step' do
        expect(subject).to eq 'Company not found'
      end
    end
  end
end
