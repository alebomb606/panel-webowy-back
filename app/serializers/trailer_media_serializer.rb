class TrailerMediaSerializer < ApplicationSerializer
  # cache_options enabled: true, cache_length: 10.minutes

  attributes :kind, :status, :camera, :uuid, :taken_at

  attribute :requested_at do |obj|
    obj.requested_at&.iso8601
  end

  attribute :requested_time do |obj|
    obj.requested_time&.iso8601
  end

  attribute :taken_at do |obj|
    obj.taken_at&.iso8601
  end

  attribute :url do |obj|
    obj.file.url
  end
end
