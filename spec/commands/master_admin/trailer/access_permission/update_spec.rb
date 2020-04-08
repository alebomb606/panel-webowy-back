require 'rails_helper'

RSpec.describe MasterAdmin::Trailer::AccessPermission::Update do
  describe '#call' do
    subject {
      described_class.new.call(params) do |m|
        m.success { |perm| perm }
        m.failure(:logistician_not_found) { 'logistician not found' }
        m.failure(:permission_not_found) { 'permission not found' }
        m.failure { |res| res }
      end
    }

    let(:logistician) { create(:logistician, :with_auth, :with_person) }
    let(:trailer)     { create(:trailer, company: logistician.person.company) }
    let(:permission)  { create(:trailer_access_permission, trailer: trailer, logistician: logistician) }

    context 'with valid params' do
      let(:params) {
        attributes_for(
          :trailer_access_permission,
          logistician_id: logistician.id
        ).merge(id: permission.id)
      }

      it 'updates permission' do
        expect(subject).to have_attributes(
          sensor_access: params[:sensor_access],
          alarm_control: params[:alarm_control],
          system_arm_control: params[:system_arm_control],
          load_in_mode_control: params[:load_in_mode_control],
          photo_download: params[:photo_download],
          video_download: params[:video_download],
          monitoring_access: params[:monitoring_access],
          current_position: params[:current_position],
          route_access: params[:route_access]
        )
      end
    end

    context 'with invalid params' do
      let(:params) {
        {
          id: permission.id,
          sensor_access: 'NOT A BOOL',
          event_log_access: :bool?
        }
      }

      let(:errors) { subject[:errors] }

      it 'returns errors' do
        expect(errors[:sensor_access]).to include(I18n.t('errors.bool?'))
        expect(errors[:event_log_access]).to include(I18n.t('errors.bool?'))
      end
    end

    context 'when logistician is archived' do
      let(:logistician) { create(:logistician, :archived, :with_person) }
      let(:params) {
        attributes_for(
          :trailer_access_permission,
          logistician_id: logistician.id
        ).merge(id: permission.id)
      }

      it 'updates permission' do
        expect(subject).to eq 'logistician not found'
      end
    end

    context 'with invalid logistician ID' do
      let(:params) {
        attributes_for(:trailer_access_permission, logistician_id: -1)
          .merge(id: permission.id)
      }

      it 'returns errors' do
        expect(subject).to eq('logistician not found')
      end
    end

    context 'with invalid trailer ID' do
      let(:params) {
        attributes_for(:trailer_access_permission, logistician_id: logistician.id)
          .merge(id: -1)
      }

      it 'returns errors' do
        expect(subject).to eq('permission not found')
      end
    end
  end
end
