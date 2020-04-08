require 'rails_helper'

RSpec.describe MasterAdmin::Logistician::UnassignTrailer do
  subject do
    described_class.new.call(params) do |m|
      m.success {}
      m.failure(:logistician_not_found) { 'Logistician not found' }
      m.failure(:trailer_not_found) { 'Trailer not found' }
      m.failure { |res| res }
    end
  end

  describe '#call' do
    context 'when valid params are passed' do
      let(:logistician) { create(:logistician, trailers: [trailer]) }
      let(:company) { create(:company) }
      let(:trailer) { create(:trailer, company: company) }
      let(:params) { { id: logistician.id, trailer_id: trailer.id } }

      it 'does not delete the trailer' do
        trailer
        expect{ subject }.not_to change{ Trailer.count }
      end

      it 'changes logistician\'s trailer count' do
        expect{ subject }.to change{ logistician.trailers.count }.by -1
      end

      it 'unassigns logistician from trailer' do
        subject
        expect{ logistician.trailers.find(trailer.id) }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'unassigns trailer from logistician' do
        subject
        expect{ trailer.logisticians.find(logistician.id) }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'when logistician is not found' do
      let(:trailer) { create(:trailer, company: company) }
      let(:company) { create(:company) }
      let(:params) { { id: -5, trailer_id: trailer.id } }

      it 'returns proper error' do
        expect(subject).to eq 'Logistician not found'
      end
    end

    context 'when logistician is archived' do
      let(:trailer) { create(:trailer, company: company) }
      let(:logistician) { create(:logistician, :archived, company: company) }
      let(:company) { create(:company) }
      let(:params) { { id: -5, trailer_id: trailer.id } }

      it 'returns proper error' do
        expect(subject).to eq 'Logistician not found'
      end
    end

    context 'when trailer is not found' do
      context 'when trailer does not exist' do
        let(:logistician) { create(:logistician) }
        let(:params) { { id: logistician.id, trailer_id: -5 } }

        it 'returns proper error' do
          expect(subject).to eq 'Trailer not found'
        end
      end

      context 'when trailer is not under logisticians surveillance' do
        let(:logistician) { create(:logistician) }
        let(:company) { create(:company) }
        let(:trailer) { create(:trailer, company: company) }
        let(:params) { { id: logistician.id, trailer_id: trailer.id } }

        it 'returns proper error' do
          expect(subject).to eq 'Trailer not found'
        end
      end
    end
  end
end
