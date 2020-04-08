require 'rails_helper'

RSpec.describe Media::ContinuousRequestWorker, type: :worker do
  let(:scheduled_job) { described_class.perform }
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
  end
end
