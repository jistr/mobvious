module Mobvious
  module Strategies
    # Mobvious device detection strategy that uses URL pattern matching.
    class URL
      # Rule set with only one rule for domains that begin with `m.` matching as `:mobile`.
      RULES_MOBILE_PATH = { /^\w+:\/\/m\./ => :mobile }

      # Creates a new URL strategy instance.
      #
      # @param rules
      #   A hash containing regular expressions mapped to symbols. The regular expression
      #   is evaluated against the whole URL of the request (including `http://`). If matching,
      #   the corresponding symbol is returned as the device type.  
      #   **or**  
      #   a symbol for one of predefined detection rules (`:mobile_path_rules`)
      # @param options
      #   A hash with strategy options.  
      #   `disable_if_referer_set: true` disables the strategy if HTTP Referer header is set  
      #   `disable_if_referer_matches: /regex/` disables the strategy if HTTP Referer matches
      #   given regular expression  
      #   `disable_unless_referer_matches: /regex/` disables the strategy if HTTP Referer
      #   doesn't match given regular expression  
      def initialize(rules = :mobile_path, options = {})
        if rules.is_a? Symbol
          @rules = eval("RULES_#{rules.to_s.upcase}")
        else
          @rules = rules
        end

        default_options = {
          disable_if_referer_set: false,
          disable_if_referer_matches: nil,
          disable_unless_referer_matches: nil
        }
        @options = default_options.merge(options)
      end

      # Gets device type using URL pattern matching. Returns nil if no match found.
      #
      # @param request [Rack::Request]
      # @return [Symbol] device type or nil
      def get_device_type(request)
        return nil if disabled_by_referer_set?(request) ||
                      disabled_by_referer_matching?(request) ||
                      disabled_by_referer_not_matching?(request)

        @rules.each do |regex, device_type|
          return device_type if request.url =~ regex
        end
        nil
      end

      private

      def disabled_by_referer_set?(request)
        @options[:disable_if_referer_set] && request.env['HTTP_REFERER']
      end

      def disabled_by_referer_matching?(request)
        @options[:disable_if_referer_matches] &&
            request.env['HTTP_REFERER'] =~ @options[:disable_if_referer_matches]
      end

      def disabled_by_referer_not_matching?(request)
        @options[:disable_unless_referer_matches] &&
            request.env['HTTP_REFERER'] !~ @options[:disable_unless_referer_matches]
      end
    end
  end
end
