class MasterAdmin::Trailer::InstallDevice < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    configure do
      def unique?(attr_name, value)
        ::Trailer.active.where(attr_name => value).empty?
      end
    end

    required(:plan_attributes).filled(:hash?)
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
      attributes = yield validate(params.to_h)
      yield find_company(attributes[:company_id])
      trailer = ::Trailer.create(attributes.except(:plan_attributes))
      yield assign_plan(trailer, attributes)
      mount_available_sensors(trailer)
      mount_available_cameras(trailer)
      Success(trailer)
    end
  end

  private

  def find_company(id)
    Try(ActiveRecord::RecordNotFound) { ::Company.active.find(id) }.or { Failure(what: :not_found) }
  end

  def validate(params)
    validation = Schema.call(params)

    if validation.failure?
      Failure(errors: validation.errors)
    else
      Success(validation.output)
    end
  end

  def assign_plan(trailer, attributes)
    ::MasterAdmin::Trailer::AssignPlan.new.call(trailer, attributes[:plan_attributes])
  end

  def mount_available_sensors(trailer)
    ::MasterAdmin::TrailerSensor::MountAvailable.new.call(trailer)
  end

  def mount_available_cameras(trailer)
    ::MasterAdmin::Trailer::Camera::MountAvailable.new.call(trailer)
  end
end
