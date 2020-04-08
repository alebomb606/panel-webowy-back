class ErrorSerializer
  def self.wrap(errors)
    errors = ::ErrorFormatter.new(errors).call
    {
      errors: errors.map do |err|
        ::ApiError.new(
          title: err[:formatted_attribute],
          detail: err[:message]
        )
      end
    }
  end

  def self.not_found(resource_name)
    {
      errors: [
        ::ApiError.new(
          status: '404',
          detail: I18n.t('errors.not_found', resource: resource_name)
        )
      ]
    }
  end

  def self.unauthorized
    {
      errors: [
        ::ApiError.new(
          status: '401',
          detail: I18n.t('errors.unauthorized')
        )
      ]
    }
  end

  def self.bad_credentials
    {
      errors: [
        ::ApiError.new(
          status: '401',
          detail: I18n.t('errors.bad_credentials')
        )
      ]
    }
  end

  def self.not_connected
    {
      errors: [
        ::ApiError.new(
          status: '500',
          detail: I18n.t('errors.not_connected')
        )
      ]
    }
  end

  def self.null_resource
    { data: nil }
  end
end
