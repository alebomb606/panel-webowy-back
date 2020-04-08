class LogisticianSerializer < ApplicationSerializer
  attributes :preferred_locale

  attribute :first_name do |obj|
    obj.person&.first_name
  end
  attribute :last_name do |obj|
    obj.person&.last_name
  end
  attribute :phone_number do |obj|
    obj.person&.phone_number
  end

  has_one :person
  has_many :trailer_access_permissions
end
