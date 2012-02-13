require 'spec_helper'
require 'mobvious/strategies/url'

module Mobvious::Strategies
class URLSpec < MiniTest::Spec
  describe URL do
    before do
      @env = Rack::MockRequest::DEFAULT_ENV
      @env.merge!({
        'rack.url_scheme' => 'http',
        'HTTP_HOST' => 'm.foo.com',
        'SERVER_PORT' => 80,
        'SCRIPT_NAME' => '',
        'PATH_INFO' => '/some_path'
      })
      @request = Rack::Request.new(@env)
      @strategy = URL.new(URL::MOBILE_PATH_RULES)
    end

    it "returns the right device type when matching rule found" do
      puts @request.url
      @strategy.get_device_type(@request).must_equal :mobile
    end

    it "returns nil if no matching rule found" do
      @env['HTTP_HOST'] = 'www.foo.com'
      @strategy.get_device_type(@request).must_equal nil
    end
  end
end
end
