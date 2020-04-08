module ErrorHelper
  def formatted_errors(errors)
    errors = ::ErrorFormatter.new(errors, error_per_key: true).call
    errors.map do |err|
      "#{err[:formatted_attribute]} #{err[:message]}"
    end
  end
end
