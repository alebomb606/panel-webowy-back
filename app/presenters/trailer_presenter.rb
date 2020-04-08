class TrailerPresenter < ApplicationPresenter
  attr_reader :trailer

  delegate :id,
    :registration_number,
    :device_serial_number,
    :make,
    :model,
    :description,
    :banana_pi_token,
    :spedition_company,
    :transport_company,
    :engine_running,
    :hqtimezone,
    :phone_number,
    :device_installed_at, to: :trailer

  def initialize(trailer)
    @trailer = trailer
  end

  def company
    @trailer.company.name
  end

  def access_permission_id(logistician:)
    @trailer.access_permissions.find_by(logistician_id: logistician.id).id
  end
end
