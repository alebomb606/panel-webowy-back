class MasterAdmin::Company::Archive < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  def call(id)
    company = yield find_company(id)
    Success(archive_company(company))
  end

  private

  def find_company(id)
    Try(ActiveRecord::RecordNotFound) { ::Company.active.find(id) }
      .or { Failure(what: :company_not_found) }
  end

  def archive_company(company)
    company.update(archived_at: Time.current)
    company.trailers.pluck(:id).map(&method(:archive_trailer))
    company.logisticians.pluck(:id).map(&method(:archive_logistician))
    company
  end

  def archive_logistician(id)
    ::MasterAdmin::Logistician::Archive.new.call(id)
  end

  def archive_trailer(id)
    ::MasterAdmin::Trailer::Archive.new.call(id)
  end
end
