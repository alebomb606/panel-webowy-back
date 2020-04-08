module Types
  include Dry::Types.module

  PhoneNumber = Types::Strict::String.constructor do |str|
    str.present? ? Phony.normalize(str) : nil
  end
end
