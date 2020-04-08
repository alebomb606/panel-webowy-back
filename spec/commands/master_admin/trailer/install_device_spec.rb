require 'rails_helper'

RSpec.describe MasterAdmin::Trailer::InstallDevice do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success {}
        m.failure(:not_found) { raise ActiveRecord::RecordNotFound }
        m.failure { |res| res }
      end
    end

    let(:company)     { create(:company) }
    let(:plan_params) { { plan_attributes: attributes_for(:plan) } }

    context 'with valid params' do
      let(:params)  { attributes_for(:trailer, company_id: company.id).merge(plan_params) }
      let(:trailer) do
        subject
        ::Trailer.last
      end

      it 'creates new trailer record' do
        expect { subject }.to change { ::Trailer.count }.by(1)
      end

      it 'creates trailer' do
        expect(trailer).to have_attributes(
          device_serial_number: params[:device_serial_number],
          registration_number: params[:registration_number],
          phone_number: params[:phone_number],
          device_installed_at: params[:device_installed_at]
        )
      end

      it 'creates plan' do
        expect(trailer.plan.kind).to eq(params[:plan_attributes][:kind])
        expect(trailer.plan.selected_features.map(&:to_s)).to match_array(params[:plan_attributes][:selected_features])
      end

      it 'assigns default sensors' do
        expect { subject }.to change { ::TrailerSensor.count }.by(::TrailerSensor.kinds.count)
      end

      it 'assigns default cameras' do
        expect { subject }.to change { ::TrailerCamera.count }.by(::TrailerCamera.camera_types.count)
      end

      it 'assigns default settings' do
        expect { subject }.to change { ::TrailerSensorSetting.count }.by(::TrailerSensor.kinds.count)
      end
    end

    context 'with invalid features' do
      let(:params)  { attributes_for(:trailer, company_id: company.id) }

      it 'does not create trailer' do
        expect { subject }.not_to change { ::Trailer.count }
      end

      it 'does not create plan' do
        expect { subject }.not_to change { ::Plan.count }
      end
    end

    context 'with empty attributes' do
      let(:params)  {
        attributes_for(:trailer,
          company_id: company.id,
          device_serial_number: '',
          registration_number: '',
          phone_number: '',
          device_installed_at: '',
          banana_pi_token: '',
          spedition_company: '',
          transport_company: '',
          make: nil,
          model: nil,
          plan_attributes: {}
        )
      }
      let(:errors)  { subject[:errors] }

      it 'does not create new trailer record' do
        expect { subject }.not_to change { ::Trailer.count }
      end

      it 'returns errors' do
        expect(errors).to include(:device_serial_number, :registration_number, :device_installed_at)
        expect(errors[:device_serial_number]).to include(I18n.t('errors.filled?'))
        expect(errors[:registration_number]).to include(I18n.t('errors.filled?'))
        expect(errors[:device_installed_at]).to include(I18n.t('errors.filled?'))
        expect(errors[:make]).to include(I18n.t('errors.filled?'))
        expect(errors[:model]).to include(I18n.t('errors.filled?'))
        expect(errors[:plan_attributes]).to include(I18n.t('errors.filled?'))
        expect(errors[:banana_pi_token]).to include(I18n.t('errors.filled?'))
      end
    end

    context 'with attributes that are not unique' do
      let!(:trailer) { create(:trailer) }
      let(:params)   { trailer.attributes }
      let(:errors)   { subject[:errors] }

      it 'does not create new trailer record' do
        expect { subject }.not_to change { ::Trailer.count }
      end

      it 'returns errors' do
        expect(errors[:device_serial_number]).to include(I18n.t('errors.unique?'))
        expect(errors[:registration_number]).to include(I18n.t('errors.unique?'))
        expect(errors[:phone_number]).to include(I18n.t('errors.unique?'))
        expect(errors[:banana_pi_token]).to include(I18n.t('errors.unique?'))
      end
    end

    context 'when trailer with the same device serial number is archived' do
      let!(:trailer) { create(:trailer, :archived) }
      let(:params)  { attributes_for(:trailer, device_serial_number: trailer.device_serial_number, company_id: company.id).merge(plan_params) }

      it 'creates new trailer' do
        expect{ subject }.to change{ Trailer.count }.by 1
      end
    end

    context 'when trailer with the same registration number is archived' do
      let!(:trailer) { create(:trailer, :archived) }
      let(:params)  { attributes_for(:trailer, registration_number: trailer.registration_number, company_id: company.id).merge(plan_params) }

      it 'creates new trailer' do
        expect{ subject }.to change{ Trailer.count }.by 1
      end
    end

    context 'when trailer is archived' do
      let(:company) { create(:company, :archived) }
      let(:params) { attributes_for(:trailer, company_id: company.id).merge(plan_params) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with non-existing company' do
      let(:params) { attributes_for(:trailer, company_id: -1).merge(plan_params) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with invalid device_serial_number' do
      let(:params) { attributes_for(:trailer, company_id: company.id, device_serial_number: 'plain_invalid') }
      let(:errors)  { subject[:errors] }

      it 'raises ActiveRecord::RecordNotFound' do
        expect(errors[:device_serial_number]).to include(I18n.t('errors.format?'))
      end
    end

    context 'with invalid make selected' do
      let(:params) { attributes_for(:trailer, company_id: company.id, make: :xyzabc) }
      let(:errors) { subject[:errors] }

      it 'raises ActiveRecord::RecordNotFound' do
        expect(errors[:make]).to include(I18n.t('errors.included_in?.arg.default', list: ::Trailer::MAKES.keys.join(', ')))
      end
    end
  end
end
