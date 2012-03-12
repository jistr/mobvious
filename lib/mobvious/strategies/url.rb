module Mobvious
  module Strategies
    # Mobvious device detection strategy that uses URL pattern matching.
    class URL
      # Rule set with only one rule for domains that begin with `m.` matching as `:mobile`.
      MOBILE_PATH_RULES = { /^\w+:\/\/m\./ => :mobile }

      # Creates a new URL strategy instance.
      #
      # @param rules
      #   A hash containing regular expressions mapped to symbols. The regular expression
      #   is evaluated against the whole URL of the request (including `http://`). If matching,
      #   the corresponding symbol is returned as the device type.
      def initialize(rules = MOBILE_PATH_RULES)
        @rules = rules
      end

      # Gets device type using URL pattern matching. Returns nil if no match found.
      #
      # @param request [Rack::Request]
      # @return [Symbol] device type or nil
      def get_device_type(request)
        @rules.each do |regex, device_type|
          return device_type if request.url =~ regex
        end
        nil
      end
    end
  end
end
