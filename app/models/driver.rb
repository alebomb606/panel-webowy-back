class Driver < ApplicationRecord
  has_one :person, as: :personifiable, dependent: :destroy

  scope :active, -> { where(archived_at: nil) }

  accepts_nested_attributes_for :person
end
