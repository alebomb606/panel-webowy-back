class DeviceMediaFile < ApplicationRecord
  KINDS = {
    photo: 0,
    video: 1
  }.freeze

  STATUSES = {
    request: 0,
    processing: 1,
    completed: 2
  }.freeze

  CAMERAS = {
    interior: 0,
    exterior: 1,
    left_top: 2,
    right_top: 3,
    left_bottom: 4,
    right_bottom: 5
  }.freeze

  mount_uploader :file, MediaFileUploader

  # reverse_geocoded_by :latitude, :longitude

  belongs_to :trailer_event, optional: true
  belongs_to :trailer, optional: true
  belongs_to :logistician, optional: true
  has_one :route_log, foreign_key: 'trailer_media_file_id', dependent: :destroy

  enum kind: KINDS
  enum status: STATUSES
  enum camera: CAMERAS
end
