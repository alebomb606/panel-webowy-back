require 'rails_helper'

RSpec.describe MasterAdmin::Logistician::Archive do
  describe '#call' do
    subject do
      described_class.new.call(params[:id]) do |r|
        r.success {}
        r.failure(:logistician_not_found) { 'Logistician not found' }
      end
    end

    context 'when logistician is already archived' do
      let(:logistician) { create(:logistician, :archived) }
      let(:params) { { id: logistician.id } }

      it 'stops the procedure at finding logistician' do
        expect(subject).to eq 'Logistician not found'
      end
    end

    context 'when logistician does not exist' do
      let(:params) { { id: -5 } }

      it 'stops the procedure at finding logistician' do
        expect(subject).to eq 'Logistician not found'
      end
    end

    context 'when logistician has auth assigned' do
      let!(:auth) { create(:auth, logistician: logistician, email: 'test@test.com') }
      let(:logistician) { create(:logistician) }
      let(:params) { { id: logistician.id } }

      it 'archives the logistician' do
        subject
        expect(logistician.reload.archived_at).not_to be_nil
      end

      it 'calls secure random' do
        expect(SecureRandom).to receive(:uuid)
        subject
      end

      it 'adds suffix to the email' do
        expect(SecureRandom).to receive(:uuid).and_return('2d931510-d99f-494a-8c67-87feb05e1594')
        subject
        expect(logistician.auth.reload.email).to eq "2d931510-d99f-494a-8c67-87feb05e1594_test@test.com"
      end
    end

    context 'when logistician does not have an auth' do
      let(:logistician) { create(:logistician) }
      let(:params) { { id: logistician.id } }

      it 'archives the logistician' do
        subject
        expect(logistician.reload.archived_at).not_to be_nil
      end

      it 'does not update auth' do
        expect_any_instance_of(Auth).not_to receive(:update)
        subject
      end
    end

    context 'when logistician exists' do
      let!(:logistician) { create(:logistician) }
      let(:params) { { id: logistician.id } }

      it 'does not delete logistician' do
        expect { subject }.not_to change { Logistician.count }
      end

      it 'changes archived at timestamp' do
        subject
        expect(logistician.reload.archived_at).not_to be_nil
      end
    end
  end
end
