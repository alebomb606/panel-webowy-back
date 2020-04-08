class Person < ApplicationRecord
  DEFAULT_SEARCH_COLUMNS = %w[first_name last_name email phone_number extra_phone_number].freeze

  belongs_to :personifiable, polymorphic: true
  belongs_to :company

  mount_uploader :avatar, ::AvatarUploader
  mount_base64_uploader :avatar, ::AvatarUploader

  scope :search, ->(keyword, columns = DEFAULT_SEARCH_COLUMNS) do
    where("concat_ws(' ', #{sanitize_sql(columns.join(', '))}) ILIKE ?", "%#{keyword}%")
  end
end
