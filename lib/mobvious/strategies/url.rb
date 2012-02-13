module Mobvious
  module Strategies
    class URL
      MOBILE_PATH_RULE = {
        /^\w+:\/\/m\./ => :mobile
      }

      def initialize(rules = MOBILE_PATH_RULE)
        @rules = rules
      end

      def get_device_type(request)
        @rules.each do |regex, device_type|
          return device_type if request.url =~ regex
        end
        nil
      end
    end
  end
end
