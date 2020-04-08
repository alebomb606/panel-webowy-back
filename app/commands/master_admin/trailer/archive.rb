class MasterAdmin::Trailer::Archive < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  def call(id)
    trailer = yield find_trailer(id)
    Success(archive_trailer(trailer))
  end

  private

  def find_trailer(id)
    Try(ActiveRecord::RecordNotFound) { ::Trailer.active.find(id) }.or { Failure(what: :trailer_not_found) }
  end

  def archive_trailer(trailer)
    trailer.update(archived_at: Time.current)
    trailer
  end
end
