class Trailer::ReadStatusPolicy < ApplicationPolicy
  def initialize(permission)
    @permission = permission
  end

  def call
    @permission.monitoring_access?
  end
end
