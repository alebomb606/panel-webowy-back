class Media::ContinuousRequestWorker
  include Sidekiq::Worker

  def perform
    ::DeviceMediaFile::ContinuousRequest.new.call
  end
end
