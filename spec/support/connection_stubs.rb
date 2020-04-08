module ConnectionStubs
  class TestConnection
    attr_reader :identifiers, :logger

    def initialize(identifiers_hash = {})
      @identifiers = identifiers_hash.keys
      @logger = ActiveSupport::Logger.new(STDOUT)

      # This is an equivalent of providing `identified_by :identifier_key`
      identifiers_hash.each do |identifier, value|
        define_singleton_method(identifier) do
          value
        end
      end
    end
  end
end
