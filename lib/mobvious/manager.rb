require 'rack'

module Mobvious
  class Manager
    def initialize(app)
      @app = app
    end

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
