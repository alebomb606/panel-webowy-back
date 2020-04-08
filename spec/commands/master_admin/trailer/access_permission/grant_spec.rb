require 'rails_helper'

RSpec.describe MasterAdmin::Trailer::AccessPermission::Grant do
  describe '#call' do
    subject {
      described_class.new.call(params) do |m|
        m.success { |perm| perm }
        m.failure(:logistician_not_found) { 'logistician not found' }
        m.failure(:trailer_not_found) { 'trailer not found' }
        m.failure { |res| res }
      end
    }

    let(:company)     { create(:company) }
    let(:trailer)     { create(:trailer, company: company) }
    let(:logistician) { create(:logistician, :with_auth) }
    let!(:person)     { create(:person, personifiable: logistician, company: company) }

    context 'with valid params' do
      context 'when logistician has no permissions defined' do
        let(:params) {
          attributes_for(:trailer_access_permission,
            logistician_id: logistician.id,
            trailer_id: trailer.id
          )
        }

        it { expect { subject }.to change { ::TrailerAccessPermission.count }.by(1) }

        it 'has valid permissions' do
          expect(subject).to have_attributes(
            logistician_id: logistician.id,
            sensor_access: params[:sensor_access],
            event_log_access: params[:event_log_access],
            alarm_control: params[:alarm_control],
            system_arm_control: params[:system_arm_control],
            load_in_mode_control: params[:load_in_mode_control],
            photo_download: params[:photo_download],
            video_download: params[:video_download],
            monitoring_access: params[:monitoring_access],
            current_position: params[:current_position],
            route_access: params[:route_access],
          )
        end
      end

      context 'when logistician has already defined permissions' do
        let!(:permissions) {
          create(:trailer_access_permission, trailer: trailer, logistician: logistician)
        }

        let(:params) {
          {
            logistician_id: logistician.id,
            trailer_id: trailer.id,
            sensor_access: false,
            event_log_access: false
          }
        }

        it { expect { subject }.not_to change { ::TrailerAccessPermission.count } }

        it 'updates existing permissions' do
          expect(subject).to have_attributes(
            sensor_access: false,
            event_log_access: false
          )
        end
      end
    end

    context 'with invalid params' do
      context 'with invalid trailer_id' do
        let(:params) { { logistician_id: logistician.id, trailer_id: -1 } }

        it 'returns not found' do
          expect(subject).to eq('trailer not found')
        end
      end

      context 'when trailer is not in the same company as logistician' do
        let(:trailer) { create(:trailer, company: other_company) }
        let(:other_company) { create(:company) }
        let(:params) { { logistician_id: logistician.id, trailer_id: trailer.id } }

        it 'stops proceeding at finding logisitican' do
          expect(subject).to eq 'logistician not found'
        end
      end

      context 'when trailer is archived' do
        let(:trailer) { create(:trailer, :archived) }
        let(:params) { { logistician_id: logistician.id, trailer_id: trailer.id } }

        it 'stops proceeding at finding trailer' do
          expect(subject).to eq 'trailer not found'
        end
      end

      context 'when logistician is archived' do
        let(:logistician) { create(:logistician, :archived) }
        let(:params) { { logistician_id: logistician.id, trailer_id: trailer.id } }

        it 'stops proceeding at finding trailer' do
          expect(subject).to eq 'logistician not found'
        end
      end

      context 'with invalid logistician_id' do
        let(:params) { { logistician_id: -1, trailer_id: trailer.id } }

        it 'returns not found' do
          expect(subject).to eq('logistician not found')
        end
      end

      context 'with invalid permissions' do
        let(:params) {
          {
            sensor_access: 'NOT A BOOL',
            event_log_access: 'NOT A BOOL EITHER',
            alarm_control: 10,
            photo_download: :xd
          }
        }

        let(:errors) { subject[:errors] }

        it 'returns errors' do
          expect(errors[:sensor_access]).to include(I18n.t('errors.bool?'))
          expect(errors[:event_log_access]).to include(I18n.t('errors.bool?'))
          expect(errors[:alarm_control]).to include(I18n.t('errors.bool?'))
          expect(errors[:photo_download]).to include(I18n.t('errors.bool?'))
        end
      end
    end
  end
end
