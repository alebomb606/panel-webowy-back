class MasterAdmin::Trailer::UpdateDevice < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      option :record

      def unique?(attr_name, value)
        ::Trailer.active.where.not(id: record.id).where(attr_name => value).empty?
      end
    end

    optional(:plan_attributes).filled(:hash?)
    required(:device_serial_number).filled(:str?, format?: /\A[A-Z]{2}\d{5}\z/, unique?: :device_serial_number)
    required(:registration_number).filled(:str?, unique?: :registration_number)
    required(:device_installed_at).filled(:time?)
    required(:company_id).filled(:int?)
    required(:make).filled(included_in?: ::Trailer.makes.keys)
    required(:model).filled(:str?)
    required(:banana_pi_token).filled(:str?, unique?: :banana_pi_token)
    optional(:description).maybe(:str?)
    optional(:spedition_company).maybe(:str?)
    optional(:transport_company).maybe(:str?)
    optional(:phone_number, Types::PhoneNumber).maybe(:str?, :phone_number?, unique?: :phone_number)
  end

  def call(params)
    ActiveRecord::Base.transaction do
      trailer = yield find_trailer(params[:id])
      yield find_company(params[:company_id])
      attributes = yield validate(trailer, params.to_h)
      trailer = update_trailer(trailer, attributes.except(:plan_attributes))
      yield update_plan(trailer, attributes) if attributes[:plan_attributes]
      Success(trailer)
    end
  end

  private

  def find_company(id)
    Try(ActiveRecord::RecordNotFound) { ::Company.active.find(id) }.or { Failure(what: :company_not_found) }
  end

  def find_trailer(id)
    Try(ActiveRecord::RecordNotFound) { ::Trailer.active.find(id) }.or { Failure(what: :trailer_not_found) }
  end

  def validate(trailer, params)
    validation = Schema
      .with(record: trailer)
      .call(params)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def update_trailer(trailer, attributes)
    trailer.update(attributes)
    trailer
  end

  def update_plan(trailer, attributes)
    ::MasterAdmin::Trailer::UpdatePlan.new.call(trailer, attributes[:plan_attributes])
  end
end
