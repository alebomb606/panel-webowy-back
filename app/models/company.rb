class Company < ApplicationRecord
  has_many :people, dependent: :destroy
  has_many :drivers,
    through: :people,
    source: :personifiable,
    source_type: 'Driver'
  has_many :logisticians,
    through: :people,
    source: :personifiable,
    source_type: 'Logistician'
  has_many :trailers, dependent: :nullify

  scope :active, -> { where(archived_at: nil) }
end
