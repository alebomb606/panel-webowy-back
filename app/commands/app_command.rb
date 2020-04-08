require 'dry/matcher'
require 'dry/monads/do'
require 'dry/monads/try'

class AppCommand
  include Dry::Monads::Result::Mixin
  include Dry::Monads::Try::Mixin

  Matcher = Dry::Matcher.new(
    success: Dry::Matcher::Case.new(
      match: ->(result) {
        result = result.to_result
        result.success?
      },
      resolve: ->(result) {
        result = result.to_result
        result.value!
      }
    ),
    failure: Dry::Matcher::Case.new(
      match: ->(result, what = nil) {
        if what
          result.to_result.failure? && result.failure[:what] == what
        else
          result.to_result.failure?
        end
      },
      resolve: ->(result) {
        result = result.to_result
        result.failure
      }
    )
  )
end
