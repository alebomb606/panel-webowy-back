class AuthSerializer < ApplicationSerializer
  attributes :id, :email

  belongs_to :logistician,
    serializer: LogisticianSerializer,
    if: proc { |record| record.logistician? }
end
