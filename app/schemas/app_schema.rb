class AppSchema < Dry::Validation::Schema
  configure do |config|
    config.messages = :i18n

    def email?(value)
      Devise.email_regexp.match?(value)
    end

    def latitude?(value)
      value >= -90 && value <= 90
    end

    def longitude?(value)
      value >= -180 && value <= 180
    end

    def speed?(value)
      value >= 0
    end

    def phone_number?(value)
      Phony.plausible?(value)
    end
  end
end
