require_relative '../spec_helper'

class MobviousSpec < MiniTest::Spec
describe Mobvious do
  describe "having real strategies" do
    before do
      require 'mobvious/strategies/cookie'
      require 'mobvious/strategies/mobileesp'
      @cookie = Mobvious::Strategies::Cookie.new [:mobile, :desktop]
      @cookie2 = Mobvious::Strategies::Cookie.new [:mobile, :desktop]
      @mobileesp = Mobvious::Strategies::Mobileesp.new
      Mobvious.config.strategies = [
        @cookie,
        @cookie2,
        @mobileesp
      ]
    end

    it "yields itself in configure block" do
      Mobvious.configure do
        strategies.must_equal Mobvious.config.strategies
      end
    end

    it "gets the right strategy by class name" do
      Mobvious.strategy('Mobileesp').must_equal @mobileesp
    end

    it "gets an array of strategies if there is more with the same name" do
      Mobvious.strategy('Cookie')[0].must_equal @cookie
      Mobvious.strategy('Cookie')[1].must_equal @cookie2
    end
  end
end
end
