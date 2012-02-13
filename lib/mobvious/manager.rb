require 'rack'

module Mobvious
  # Rack middleware that enables device type detection for requests.
  #
  # Use `Mobvious.config` to set which strategies to use.
  #
  # Look into `Mobvious::Strategies` for predefined strategies or write your own.
  class Manager
    # Create a new instance of this rack middleware.
    #
    # @param app Rack application that can be called.
    def initialize(app)
      @app = app
    end

    # Perform the device type detection and call the inner Rack application.
    #
    # @param env Rack environment.
    # @return rack response `[status, headers, body]`
    def call(env)
      request = Rack::Request.new(env)
      assign_device_type(request)

      status, headers, body = @app.call(env)

      response = Rack::Response.new(body, status, headers)
      response_callback(request, response)

      [status, headers, body]
    end

    private
      def assign_device_type(request)
        request.env['mobvious.device_type'] =
            get_device_type_using_strategies(request) || config.default_device_type
      end

      def response_callback(request, response)
        config.strategies.each do |strategy|
          strategy.response_callback(request, response) if strategy.respond_to? :response_callback
        end
      end

      def get_device_type_using_strategies(request)
        config.strategies.each do |strategy|
          result = strategy.get_device_type(request)
          return result.to_sym if result
        end
        nil
      end

      def config
        Mobvious.config
      end
  end
end
