require 'rails_helper'

RSpec.describe MasterAdmin::Company::Archive do
  describe '#call' do
    subject do
      described_class.new.call(params[:id]) do |r|
        r.success {}
        r.failure(:company_not_found) { 'Company not found' }
      end
    end

    context 'when company does not exist' do
      let(:params) { { id: -5 } }

      it 'stops procedure at finding the company' do
        expect(subject).to eq 'Company not found'
      end
    end

    context 'when company is already archived' do
      let!(:company) { create(:company, :archived) }
      let(:params) { { id: company.id } }

      it 'stops procedure at finding the company' do
        expect(subject).to eq 'Company not found'
      end
    end

    context 'when company exists' do
      let!(:company) { create(:company) }
      let(:params) { { id: company.id } }

      it 'does not delete the company' do
        expect{ subject }.not_to change{ Company.count }
      end

      it 'changes archived at timestamp' do
        subject
        expect(company.reload.archived_at).not_to be_nil
      end

      context 'when company has trailers assigned' do
        let!(:trailer) { create(:trailer, company: company) }

        it 'archives trailers' do
          subject
          expect(trailer.reload.archived_at).not_to be_nil
        end
      end

      context 'when company has logisticians assigned' do
        let(:logistician) { create(:logistician) }
        let!(:person) { create(:person, personifiable: logistician, company: company) }

        it 'archives logisticians' do
          subject
          expect(logistician.reload.archived_at).not_to be_nil
        end
      end
    end
  end
end
