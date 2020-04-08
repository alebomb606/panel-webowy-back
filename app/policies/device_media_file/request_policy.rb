class DeviceMediaFile::RequestPolicy < ApplicationPolicy
  def self.call(permission, media_kind)
    return permission.photo_download? if media_kind == 'photo'

    media_kind == 'video' && permission.video_download?
  end
end
