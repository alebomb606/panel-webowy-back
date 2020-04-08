class Api::V1::People::FilterQuery < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:auth).filled
    optional(:filter).schema do
      optional(:keyword).filled(:str?)
    end
  end

  def call(params)
    attributes  = yield validate(params.to_h)
    filter      = attributes[:filter] || {}
    result      = fetch_people(attributes[:auth]).merge(search_scope(filter[:keyword]))

    Success(result)
  end

  private

  def validate(params)
    validated = Schema.call(params)
    return Failure(errors: validated.errors) if validated.failure?

    Success(validated.output)
  end

  def fetch_people(auth)
    auth.logistician.person.company.people.order(id: :asc)
  end

  def search_scope(keyword)
    return ::Person.all if keyword.blank?

    ::Person.search(keyword)
  end
end
