require 'spec_helper'
require 'mobvious/strategies/mobileesp'

module Mobvious::Strategies
  class MobileespSpec < MiniTest::Spec
  describe Mobileesp do
    describe "using mobile_desktop strategy" do
      before do
        @strategy = Mobvious::Strategies::Mobileesp.new
        @request = mock 'request'
        @request.stubs(:accept).returns('text/html')
      end

      it "categorizes iPhone as :mobile" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7")
        @strategy.get_device_type(@request).must_equal :mobile
      end

      it "categorizes Android tablet as :desktop" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (Linux; U; Android 3.0; xx-xx; Xoom Build/HRI39) AppleWebKit/525.10+ (KHTML, like Gecko) Version/3.0.4 Mobile Safari/523.12.2")
        @strategy.get_device_type(@request).must_equal :desktop
      end

      it "categorizes Chrome on Linux as :desktop" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11")
        @strategy.get_device_type(@request).must_equal :desktop
      end
    end

    describe "using mobile_tablet_desktop strategy" do
      before do
        @strategy = Mobvious::Strategies::Mobileesp.new(
          Mobvious::Strategies::Mobileesp::DEVICE_TYPES_MOBILE_TABLET_DESKTOP)
        @request = mock 'request'
        @request.stubs(:accept).returns('text/html')
      end

      it "categorizes iPhone as :mobile" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7")
        @strategy.get_device_type(@request).must_equal :mobile
      end

      it "categorizes Android tablet as :tablet" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (Linux; U; Android 3.0; xx-xx; Xoom Build/HRI39) AppleWebKit/525.10+ (KHTML, like Gecko) Version/3.0.4 Mobile Safari/523.12.2")
        @strategy.get_device_type(@request).must_equal :tablet
      end

      it "categorizes Chrome on Linux as :desktop" do
        @request.stubs(:user_agent).returns("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11")
        @strategy.get_device_type(@request).must_equal :desktop
      end
    end
  end
  end
end

