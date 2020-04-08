class MasterAdmin < ApplicationRecord
  has_one :auth, dependent: :destroy
end
