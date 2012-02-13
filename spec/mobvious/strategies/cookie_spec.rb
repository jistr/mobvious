require 'spec_helper'
require 'mobvious/strategies/cookie'

module Mobvious::Strategies
class CookieSpec < MiniTest::Spec
  describe Cookie do
    before do
      @strategy = Cookie.new
      @app = mock 'app'
      @uri = URI("http://foo.com/")

      @env = Rack::MockRequest::DEFAULT_ENV
      @request = Rack::Request.new(@env)
      @response = Rack::Response.new(['body'], 200, {})

      @mock_session = Rack::MockSession.new(@app)
      @mock_session.after_request do
        @strategy.response_callback(@request, @response)
      end
    end

    describe "with no device type cookie set" do
      it "returns nil as device type" do
        @strategy.get_device_type(@request).must_equal nil
      end

      describe "when device type set during the app execution" do
        it "sets the cookie on response" do
          @app.expects(:call).returns([@response.status, @response.headers, @response.body])
            .with do |env|
              @strategy.set_device_type_cookie(@response, :tablet)
              true
            end
          @mock_session.request @uri, @env
          cookies = Mobvious::CookieParser.new(@response.headers['Set-Cookie'])
          cookies['mobvious.device_type']['value'].must_equal 'tablet'
        end
      end
    end

    describe "with set device type cookie" do
      before do
        @request = Rack::Request.new(@env)
        @request.cookies['mobvious.device_type'] = 'tablet'
      end

      it "gets device type from cookie" do
        @app.expects(:call).returns([@response.status, @response.headers, @response.body])
          .with do |env|
            @strategy.get_device_type(@request).must_equal :tablet
            true
          end
        mock_response = @mock_session.request @uri, @env
      end

      it "refreshes the cookie expiration date with every request" do
        @app.expects(:call).returns([@response.status, @response.headers, @response.body])
        mock_response = @mock_session.request @uri, @env
        cookies = Mobvious::CookieParser.new(@response.headers['Set-Cookie'])
        cookies['mobvious.device_type'].wont_be_nil
        cookies['mobvious.device_type']['value'].must_equal 'tablet'
        cookies['mobvious.device_type']['expires'].wont_be_nil
      end

      describe "when device type set during the app execution" do
        it "sets the response cookie to the new value, not the old one" do
          @app.expects(:call).returns([@response.status, @response.headers, @response.body])
            .with do |env|
              @strategy.set_device_type_cookie(@response, :mobile)
              true
            end
          @mock_session.request @uri, @env
          cookies = Mobvious::CookieParser.new(@response.headers['Set-Cookie'])
          cookies['mobvious.device_type'].wont_be_nil
          cookies['mobvious.device_type']['value'].must_equal 'mobile'
          cookies['mobvious.device_type']['expires'].wont_be_nil
        end
      end
    end
  end
end
end

