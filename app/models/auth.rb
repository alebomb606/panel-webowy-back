class Auth < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable,
    :confirmable, :lockable, :timeoutable, :trackable

  include DeviseTokenAuth::Concerns::User

  belongs_to :logistician, optional: true
  belongs_to :master_admin, optional: true

  def user
    master_admin || logistician
  end

  def master_admin?
    master_admin.present?
  end

  def logistician?
    logistician.present?
  end
end
