require 'rails_helper'

RSpec.describe MasterAdmin::Driver::Update do
  describe '#call' do
    subject do
      described_class.new.call(params) do |m|
        m.success { |driver| driver }
        m.failure(:company_not_found) { 'company not found' }
        m.failure(:driver_not_found) { 'driver not found' }
        m.failure { |res| res }
      end
    end

    let(:driver)     { create(:driver) }
    let(:attributes) { driver.person.attributes.symbolize_keys }

    context 'with valid params' do
      let(:params) { { person_attributes: attributes.merge(first_name: 'Pudzian', email: nil), id: driver.id } }

      it 'updates driver\'s name and email' do
        expect(subject.person).to have_attributes(first_name: 'Pudzian', email: nil)
      end
    end

    context 'when company is not found' do
      let(:params) { { person_attributes: attributes.merge(company_id: -1), id: driver.id } }

      it 'returns not found error' do
        expect(subject).to eq('company not found')
      end
    end

    context 'when company is archived' do
      let(:params) { { person_attributes: attributes, id: driver.id } }

      before do
        driver.person.company.update(archived_at: Time.current)
      end

      it 'returns not found error' do
        expect(subject).to eq('company not found')
      end
    end

    context 'when driver is not found' do
      let(:params) { { person_attributes: attributes, id: -1 } }

      it 'returns not found error' do
        expect(subject).to eq('driver not found')
      end
    end

    context 'when driver is archived' do
      let(:driver) { create(:driver, :archived) }
      let(:params) { { person_attributes: attributes, id: driver.id } }

      it 'returns not found error' do
        expect(subject).to eq('driver not found')
      end
    end

    context 'with invalid params' do
      let(:params) { { person_attributes: { email: 'dadasd' }, id: driver.id } }
      let(:errors) { subject[:errors] }

      it 'returns errors' do
        expect(errors[:person_attributes]).to include(:first_name, :last_name, :phone_number, :email)
        expect(errors[:person_attributes][:email]).to include(I18n.t('errors.email?'))
      end
    end
  end
end
