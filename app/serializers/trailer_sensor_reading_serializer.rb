class TrailerSensorReadingSerializer < ApplicationSerializer
  attributes :original_value, :value, :value_percentage, :status

  attribute :read_at do |obj|
    obj.read_at&.iso8601
  end
end
