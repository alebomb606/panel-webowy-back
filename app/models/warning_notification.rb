class WarningNotification < ApplicationRecord
  KINDS = { email: 0, sms: 1 }.freeze

  belongs_to :trailer_sensor_reading

  enum kind: KINDS
end
