class MasterAdmin::Logistician::Archive < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  def call(id)
    logistician = yield find_logistician(id)
    Success(archive_logistician(logistician))
  end

  private

  def find_logistician(id)
    Try(ActiveRecord::RecordNotFound) { ::Logistician.active.find(id) }
      .or { Failure(what: :logistician_not_found) }
  end

  def archive_logistician(logistician)
    logistician.auth&.update(email: "#{SecureRandom.uuid}_#{logistician.auth.email}")
    logistician.update(archived_at: Time.current)
    logistician
  end
end
