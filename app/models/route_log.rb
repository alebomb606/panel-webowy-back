class RouteLog < ApplicationRecord
  reverse_geocoded_by :latitude, :longitude

  belongs_to :trailer, optional: true
  belongs_to :trailer_event, optional: true
  belongs_to :trailer_media_file, optional: true, class_name: 'DeviceMediaFile'
end
