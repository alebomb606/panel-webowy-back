require 'rails_helper'

RSpec.describe Media::CheckIfContinuousRequestProcessedWorker, type: :worker do
  let!(:media_file) { create(:device_media_file, status: 'request') }
  let(:time) { (Time.zone.today + 6.hours).to_datetime }
  let(:scheduled_job) { described_class.perform_at(time, media_id: media_file.id) }
  describe 'testing worker' do
    it 'jobs are enqueued in the default queue' do
      described_class.perform_async
      assert_equal "default", described_class.queue
    end
    it 'goes into the jobs array for testing environment' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).by(1)
      described_class.new.perform
    end
    context 'occurs daily' do
      it 'occurs at expected time' do
        scheduled_job
        assert_equal true, described_class.jobs.last['jid'].include?(scheduled_job)
        expect(described_class).to have_enqueued_sidekiq_job(media_id: media_file.id)
      end
    end
  end
end
