# rubocop:disable Metrics/LineLength
# rubocop:disable Style/StringLiteralsInInterpolation

class MediaFileUploader < CarrierWave::Uploader::Base
  storage :fog

  def extension_whitelist
    %w[jpg jpeg png mp4]
  end

  def filename
    "#{model.kind}-#{model.trailer&.device_serial_number}-#{model.taken_at&.strftime("%Y%m%d-%H%M")}.#{file.extension}" if original_filename.present?
  end
end

# rubocop:enable Style/StringLiteralsInInterpolation
# rubocop:enable Metrics/LineLength
