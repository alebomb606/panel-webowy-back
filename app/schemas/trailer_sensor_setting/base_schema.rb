class TrailerSensorSetting::BaseSchema < ParamSchema
  configure do
    config.type_specs = true
  end

  PhoneNumbers = Types::Params::Array.of(Types::PhoneNumber)

  define! do
    required(:auth, Types::Instance(::Auth)).filled
    required(:id, :integer).filled(:int?)

    required(:alarm_primary_value, :float).filled { int? | float? }
    optional(:alarm_secondary_value, :float).filled { int? | float? }
    required(:warning_primary_value, :float).filled { int? | float? }
    optional(:warning_secondary_value, :float).filled { int? | float? }

    optional(:send_sms, :bool).filled(:bool?)
    optional(:send_email, :bool).filled(:bool?)
    optional(:phone_numbers, PhoneNumbers).maybe(:array?) do
      each { phone_number? }
    end
    optional(:email_addresses, Types::Params::Array).maybe(:array?) do
      each { email? }
    end

    rule(filled?: %i[send_sms phone_numbers]) do |send_sms, phone_numbers|
      send_sms.true? > phone_numbers.filled?
    end

    rule(filled?: %i[send_email email_addresses]) do |send_email, email_addresses|
      send_email.true? > email_addresses.filled?
    end
  end
end
