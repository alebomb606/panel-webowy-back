require 'rails_helper'

RSpec.describe TrailerDataUsage::ParseReportWorker, type: :worker do
  let!(:trailer_data_usage_sync) { create(:trailer_data_usage_sync, last_sync_at: 10.days.ago, updated_trailers: 0) }
  let!(:trailer_1) { create(:trailer, phone_number: '+48660069257') }
  let!(:trailer_2) { create(:trailer, phone_number: '+48734210519') }

  subject { described_class.new.perform }

  describe '#perform' do
    context 'with valid report' do
      before do
        allow_any_instance_of(TrailerDataUsage::ParseReport).to receive(:current_report?).and_return(true)
      end

      it 'update trailer_1 data_usage' do
        expect { subject }.to change { trailer_1.reload.data_usage }.to({ "rest_percent"=>99, "rest_percentUE"=>nil, "updated_at"=>"2020-03-03" })
      end

      it 'update trailer_2 data_usage' do
        expect { subject }.to change { trailer_2.reload.data_usage }.to({ "rest_percent"=>100, "rest_percentUE"=>100, "updated_at"=>"2020-03-03" })
      end

      it 'update trailer_data_usage_sync - last_sync_at' do
        expect { subject }.to change { trailer_data_usage_sync.reload.last_sync_at.strftime('%Y-%m-%d') }.to(Time.current.strftime('%Y-%m-%d'))
      end

      it 'update trailer_data_usage_sync - updated_trailers' do
        expect { subject }.to change { trailer_data_usage_sync.reload.updated_trailers }.from(0).to(2)
      end
    end

    context 'without report' do
      before do
        allow_any_instance_of(TrailerDataUsage::ParseReport).to receive(:fetch_report).and_return(nil)
      end

      it 'does not update any data' do
        expect(subject).to eq(nil)
      end
    end

    context 'with already_sync report' do
      before do
        allow_any_instance_of(TrailerDataUsage::ParseReport).to receive(:already_sync?).and_return(true)
      end

      it 'does not update any data' do
        expect(subject).to eq(nil)
      end
    end
  end
end
