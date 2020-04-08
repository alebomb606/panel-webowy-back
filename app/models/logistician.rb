class Logistician < ApplicationRecord
  LOCALES = {
    pl: 0,
    en: 1,
    de: 2
  }.freeze

  has_one  :auth, dependent: :destroy
  has_one  :person, as: :personifiable, dependent: :destroy
  has_many :trailer_access_permissions, dependent: :destroy
  has_many :trailers, through: :trailer_access_permissions
  has_many :device_media_files, dependent: :nullify

  scope :active, -> { where(archived_at: nil) }

  accepts_nested_attributes_for :person

  enum preferred_locale: LOCALES
end
