module Mobvious
  module Strategies
    class Cookie
      def initialize(cookie_expires = (365*24*60*60))
        @cookie_expires = cookie_expires
      end

      def get_device_type(request)
        request.cookies['mobvious.device_type'].to_sym if request.cookies['mobvious.device_type']
      end

      def response_callback(request, response)
        response_cookie_already_set = !!response.headers["Set-Cookie"] && !!response.headers["Set-Cookie"]["mobvious.device_type"]
        request_cookie = request.cookies['mobvious.device_type']

        # re-set the cookie to renew the expiration date
        if request_cookie && !response_cookie_already_set
          set_device_type_cookie(response, request_cookie)
        end
      end

      def set_device_type_cookie(response, device_type)
        response.set_cookie('mobvious.device_type',
                            { value: device_type.to_s, path: '/', expires: Time.now + @cookie_expires })
      end
    end
  end
end