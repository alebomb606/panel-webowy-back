class Media::UploadWorker
  include Sidekiq::Worker

  def perform(media_id, file_path)
    media = DeviceMediaFile.find(media_id)
    media.update(file: File.open(file_path), status: 'completed')
    ::Api::V1::DeviceMediaFile::Broadcast.call(media)
  end
end
