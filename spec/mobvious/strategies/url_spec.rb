require_relative '../../spec_helper'

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
      @strategy = URL.new
    end

    it "returns the right device type when matching rule found" do
      @strategy.get_device_type(@request).must_equal :mobile
    end

    it "returns nil if no matching rule found" do
      @env['HTTP_HOST'] = 'www.foo.com'
      @strategy.get_device_type(@request).must_equal nil
    end

    describe "disabled if referer is set" do
      before do
        @strategy = URL.new(URL::MOBILE_PATH_RULES, disable_if_referer_set: true)
        @env.merge!({
          'HTTP_REFERER' => 'http://localhost'
        })
      end

      it "returns nil even when matching rule found" do
        @strategy.get_device_type(@request).must_equal nil
      end
    end

    describe "disabled if referer is set" do
      before do
        @strategy = URL.new(URL::MOBILE_PATH_RULES, disable_if_referer_set: true)
        @env.merge!({
          'HTTP_REFERER' => 'http://localhost'
        })
      end

      it "returns nil even when matching rule found" do
        @strategy.get_device_type(@request).must_equal nil
      end
    end

    describe "disabled if referer matches" do
      before do
        @env.merge!({
          'HTTP_REFERER' => 'http://localhost'
        })
      end

      it "returns nil even when matching rule found" do
        @strategy = URL.new(URL::MOBILE_PATH_RULES, disable_if_referer_matches: /local/)
        @strategy.get_device_type(@request).must_equal nil

        @strategy = URL.new(URL::MOBILE_PATH_RULES, disable_if_referer_matches: /nothing/)
        @strategy.get_device_type(@request).must_equal :mobile
      end
    end

    describe "disabled unless referer matches" do
      before do
        @env.merge!({
          'HTTP_REFERER' => 'http://localhost'
        })
      end

      it "returns nil even when matching rule found" do
        @strategy = URL.new(URL::MOBILE_PATH_RULES, disable_unless_referer_matches: /nothing/)
        @strategy.get_device_type(@request).must_equal nil

        @strategy = URL.new(URL::MOBILE_PATH_RULES, disable_unless_referer_matches: /local/)
        @strategy.get_device_type(@request).must_equal :mobile
      end
    end

    describe "using custom rules" do
      before do
        @strategy = URL.new(/\.foo\./ => :test)
      end

      it "returns :test for any url" do
        @strategy.get_device_type(@request).must_equal :test
      end
    end
  end
end
end
