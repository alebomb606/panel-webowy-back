class ErrorFormatter
  def initialize(errors, options = {})
    @error_per_key = options[:error_per_key]
    @errors        = errors
  end

  def call
    formatted_errors(@errors).flatten
  end

  private

  def formatted_errors(errors, prefix = nil)
    errors.map do |attribute, messages|
      if messages.is_a?(Hash)
        formatted_errors(messages, attribute)
      else
        formatted_messages(attribute, messages, prefix)
      end
    end
  end

  def formatted_messages(attribute, messages, prefix = nil)
    return error_details(messages, attribute) unless messages.is_a?(Array)

    title = attribute
    title = "#{prefix}.#{attribute}" if title.is_a? Integer
    return error_details(messages.first, title) if @error_per_key

    messages.map do |msg|
      error_details(msg, title)
    end
  end

  def formatted_attribute(attribute)
    key = "errors.attributes.#{attribute}"
    return I18n.t(key) if I18n.exists?(key)

    attribute.to_s.humanize
  end

  def error_details(message, attribute)
    {
      message: message,
      attribute: attribute,
      formatted_attribute: formatted_attribute(attribute)
    }
  end
end
