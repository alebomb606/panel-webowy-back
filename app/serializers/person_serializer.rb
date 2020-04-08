class PersonSerializer < ApplicationSerializer
  attributes :first_name, :last_name, :phone_number, :extra_phone_number, :email

  attribute :avatar_url do |obj|
    "https://#{Rails.application.secrets.host}#{obj.avatar.url}" if obj.avatar.present?
  end

  attribute :position do |obj|
    obj.personifiable_type.underscore
  end
end
