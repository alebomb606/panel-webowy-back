class TrailerAccessPermission < ApplicationRecord
  belongs_to :logistician
  belongs_to :trailer
end
