class TrailerCamera < ApplicationRecord
  belongs_to :trailer

  CAMERA_TYPES = {
    interior: 0,
    exterior: 1,
    left_top: 2,
    right_top: 3,
    left_bottom: 4,
    right_bottom: 5
  }.freeze
  enum camera_type: CAMERA_TYPES
end
