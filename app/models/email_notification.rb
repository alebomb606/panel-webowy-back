class EmailNotification < ApplicationRecord
  EMAIL_PRIORITIES = { high: 1, normal: 3, low: 5 }.freeze
  enum email_priority: EMAIL_PRIORITIES
end
