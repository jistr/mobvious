require_relative '../../spec_helper'

module Mobvious::Strategies
  class MobileESPSpec < MiniTest::Spec
  describe MobileESP do
    before do
      @request = mock 'request'
      @env = mock 'env'

      @request.stubs(:env).returns(@env)
      @env.stubs('[]').with('HTTP_ACCEPT').returns('text/html')
    end

    describe "using default (mobile_desktop) strategy" do
      before do
        @strategy = Mobvious::Strategies::MobileESP.new
      end

      it "categorizes iPhone as :mobile" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7")
        @strategy.get_device_type(@request).must_equal :mobile
      end

      it "categorizes Android tablet as :desktop" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (Linux; U; Android 3.0; en-us; Xoom Build/HRI39) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13")
        @strategy.get_device_type(@request).must_equal :desktop
      end

      it "categorizes Chrome on Linux as :desktop" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11")
        @strategy.get_device_type(@request).must_equal :desktop
      end
    end

    describe "using mobile_tablet_desktop strategy" do
      before do
        @strategy = Mobvious::Strategies::MobileESP.new(:mobile_tablet_desktop)
      end

      it "categorizes iPhone as :mobile" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7")
        @strategy.get_device_type(@request).must_equal :mobile
      end

      it "categorizes Android tablet as :tablet" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (Linux; U; Android 3.0; en-us; Xoom Build/HRI39) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13")
        @strategy.get_device_type(@request).must_equal :tablet
      end

      it "categorizes Chrome on Linux as :desktop" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11")
        @strategy.get_device_type(@request).must_equal :desktop
      end
    end

    describe "custom strategy" do
      before do
        procedure = lambda {|mobileesp|
          return :test
        }
        @strategy = Mobvious::Strategies::MobileESP.new(procedure)
      end

      it "categorizes anything as :test" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11")
        @strategy.get_device_type(@request).must_equal :test
      end
    end
  end
  end
end

