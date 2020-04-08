class MasterAdmin::Logistician::UnassignTrailer < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  def call(params)
    logistician = yield find_logistician(params[:id])
    trailer = yield find_trailer(logistician, params[:trailer_id])
    unassign_trailer(trailer.id, logistician.id)
    Success(logistician)
  end

  private

  def find_logistician(id)
    Try(ActiveRecord::RecordNotFound) { ::Logistician.active.find(id) }
      .or { Failure(what: :logistician_not_found) }
  end

  def find_trailer(logistician, id)
    Try(ActiveRecord::RecordNotFound) { logistician.trailers.active.find(id) }
      .or { Failure(what: :trailer_not_found) }
  end

  def unassign_trailer(trailer_id, logistician_id)
    TrailerAccessPermission
      .find_by(trailer_id: trailer_id, logistician_id: logistician_id)
      .destroy
  end
end
