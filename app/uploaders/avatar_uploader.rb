class AvatarUploader < CarrierWave::Uploader::Base
  storage :file

  def extension_whitelist
    %w[jpg jpeg png]
  end

  def asset_host
    nil
  end
end
