require 'rails_helper'

RSpec.describe MasterAdmin::Trailer::Archive do
  describe '#call' do
    subject do
      described_class.new.call(params[:id]) do |r|
        r.success {}
        r.failure(:trailer_not_found) { 'Trailer not found' }
      end
    end

    context 'when trailer is already archived' do
      let(:trailer) { create(:trailer, :archived) }
      let(:params) { { id: trailer.id } }
      it 'stops the procedure at finding the trailer' do
        expect(subject).to eq 'Trailer not found'
      end
    end

    context 'when trailer does not exist' do
      let(:params) { { id: -5 } }

      it 'stops the procedure at finding the trailer' do
        expect(subject).to eq 'Trailer not found'
      end
    end

    context 'when trailer exists' do
      let!(:trailer) { create(:trailer) }
      let(:params) { { id: trailer.id } }

      it 'does not delete the trailer' do
        expect { subject }.not_to change{ Trailer.count }
      end

      it 'changes the archived at timestamp' do
        subject
        expect(trailer.reload.archived_at).not_to be_nil
      end
    end
  end
end
