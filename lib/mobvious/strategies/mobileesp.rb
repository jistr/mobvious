require 'mobileesp'

module Mobvious
  module Strategies
    # Mobvious device detection strategy that uses user-agent sniffing provided by
    # the MobileESP library.
    class Mobileesp
      # Detection procedure that classifies mobile phones as `:mobile` and anything
      # else as `:desktop`.
      DEVICE_TYPES_MOBILE_DESKTOP = lambda {|mobileesp|
        return :mobile if mobileesp.is_tier_generic_mobile || mobileesp.is_tier_iphone
        return :desktop
      }

      # Detection procedure that classifies mobile phones as `:mobile`, tablets as
      # `:tablet` and anything else as `:desktop`.
      DEVICE_TYPES_MOBILE_TABLET_DESKTOP = lambda {|mobileesp|
        return :mobile if mobileesp.is_tier_generic_mobile || mobileesp.is_tier_iphone
        return :tablet if mobileesp.is_tier_tablet
        return :desktop
      }

      # Creates a new instance of MobileESP strategy.
      #
      # @param detection_procedure
      #   A lambda function that gets one parameter (`MobileESP::UserAgentInfo` instance)
      #   and returns device type symbol or nil.
      def initialize(detection_procedure = DEVICE_TYPES_MOBILE_DESKTOP)
        @detection_procedure = detection_procedure
      end

      # Gets device type using user-agent sniffing. Can return nil if the used
      # detection procedure does so.
      #
      # @param request [Rack::Request]
      # @return [Symbol] device type or nil
      def get_device_type(request)
        mobileesp = MobileESP::UserAgentInfo.new(request.user_agent, request.env['HTTP_ACCEPT'])
        @detection_procedure.call(mobileesp)
      end
    end
  end
end
