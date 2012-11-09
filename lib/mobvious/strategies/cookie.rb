module Mobvious
  module Strategies
    # Mobvious device detection strategy that saves and loads a cookie that precisely
    # specifies which device type should be used for current client.
    #
    # Usually, you will want to set the device type via cookie only when you are absolutely
    # sure that user wants it this way (e.g. after manual switch between mobile/desktop
    # interface versions performed by user). Also make sure to use this strategy with high
    # priority, (e.g. put it before user-agent based detection) so it does not get overriden.
    #
    # Use {Cookie#set_device_type} method to set the device type and the strategy will then
    # recognize it on subsequent requests.
    class Cookie
      # Creates a new Cookie strategy instance.
      #
      # @param allowed_device_types [Array<Symbol>]
      #   A whitelist of all device types that can be returned by this strategy. This is
      #   a security measure against modifying the cookies on client side.
      # @param cookie_expires [Integer]
      #   Amount of seconds to hold device type cookie. Defaults to one year (365*24*60*60).
      def initialize(allowed_device_types, cookie_expires = (365*24*60*60))
        @cookie_expires = cookie_expires

        # device types must be compared with the cookie as strings to prevent attacks
        # against .to_sym that could lead to memory leaks
        @allowed_device_types = allowed_device_types.map {|device_type| device_type.to_s }
      end

      # Gets device type using a pre-set cookie. Returns nil if the cookie is not set or its
      # value is not listed among `allowed_device_types` (the list can be defined in {#initialize}).
      #
      # @param request [Rack::Request]
      # @return [Symbol] device type or nil
      def get_device_type(request)
        cookie_value = request.cookies['mobvious.device_type']
        cookie_value.to_sym if @allowed_device_types.include? cookie_value
      end

      # Automatically sets the device type cookie again to prolong its expiration date.
      #
      # @param request [Rack::Request]
      # @param response [Rack::Response]
      def response_callback(request, response)

        # Sprockets::StaticAsset has no method :headers

        if response.respond_to? :headers

          response_cookie_already_set = !!response.headers["Set-Cookie"] &&
            !!response.headers["Set-Cookie"]["mobvious.device_type"]
          request_cookie = request.cookies['mobvious.device_type']

          # re-set the cookie to renew the expiration date
          if request_cookie && !response_cookie_already_set
            set_device_type(response, request_cookie)
          end

        end
      end

      # Sets the device type cookie.
      #
      # @param response [Rack::Response]
      # @param device_type [Symbol] A device type symbol (or string).
      def set_device_type(response, device_type)
        response.set_cookie('mobvious.device_type',
                            { value: device_type.to_s, path: '/', expires: Time.now + @cookie_expires })
      end
    end
  end
end
