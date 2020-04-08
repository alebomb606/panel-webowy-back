class ApiError < Dry::Struct
  module Types
    include Dry::Types.module
  end

  OptionalString = Types::Strict::String.optional.meta(omittable: true)

  attribute :title, OptionalString
  attribute :detail, OptionalString
  attribute :code, OptionalString
  attribute :status, OptionalString
  attribute :source, Types::Strict::Hash.optional.meta(omittable: true)
end
