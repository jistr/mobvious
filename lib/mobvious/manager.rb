require 'rack'

module Mobvious
  class Manager
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      assign_device_type(request)
      @app.call(env)
    end

    private
      def assign_device_type(request)
        request.env['mobvious.device_type'] =
            get_device_type_using_strategies(request) || config.default_device_type
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
