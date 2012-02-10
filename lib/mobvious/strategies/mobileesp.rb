require 'mobileesp'

module Mobvious
  module Strategies
    class Mobileesp
      DEVICE_TYPES_MOBILE_DESKTOP = lambda {|mobileesp|
        return :mobile if mobileesp.is_tier_generic_mobile || mobileesp.is_tier_iphone
        return :desktop
      }
      DEVICE_TYPES_MOBILE_TABLET_DESKTOP = lambda {|mobileesp|
        return :mobile if mobileesp.is_tier_generic_mobile || mobileesp.is_tier_iphone
        return :tablet if mobileesp.is_tier_tablet
        return :desktop
      }

      def initialize(detection_procedure = DEVICE_TYPES_MOBILE_DESKTOP)
        @detection_procedure = detection_procedure
      end

      def get_device_type(request)
        mobileesp = MobileESP::UserAgentInfo.new(request.user_agent, request.accept)
        @detection_procedure.call(mobileesp)
      end
    end
  end
end
