require 'spec_helper'

module Mobvious
  class ManagerSpec < MiniTest::Spec
  describe Manager do
    before do
      @app = mock 'app'
      @env = mock 'env'
      @manager = Mobvious::Manager.new(@app)
      @return_value = [200, ['My-Header'], ['body_part_1']]

      @app.stubs(:call).with(@env).returns(@return_value)
    end

    after do
      Mobvious.config.clear
    end

    it "calls the app and returns what app returns" do
      @env.stub_everything
      @app.expects(:call).with(@env).returns(@return_value)
      @manager.call(@env).must_equal @return_value
    end

    describe "having strategies" do
      before do
        @strategy1 = mock 'strategy1'
        @strategy2 = mock 'strategy2'
        @strategy3 = mock 'strategy3'
        Mobvious.config.strategies << @strategy1
        Mobvious.config.strategies << @strategy2
        Mobvious.config.strategies << @strategy3
      end

      it "uses the result of the first successful strategy" do
        @app.stub_everything
        @app.expects(:call).with(@env).returns(@return_value)
        @strategy1.expects(:get_device_type).returns(nil)
        @strategy2.expects(:get_device_type).returns(:strategy_2_result)
        @env.expects('[]=').with('mobvious.device_type', :strategy_2_result)
        @manager.call(@env)
      end

      it "calls strategies with a request object" do
        @app.stub_everything
        @env.stub_everything
        @strategy1.expects(:get_device_type).returns(:result).with() {|param|
          param.must_be_instance_of Rack::Request
          (param.env == @env).must_equal true
        }
        @manager.call(@env)
      end

      it "uses default value if no strategy is successful" do
        @app.stub_everything
        @strategy1.stub_everything
        @strategy2.stub_everything
        @strategy3.stub_everything
        Mobvious.config.default_device_type = :test_default_type
        @env.expects('[]=').with('mobvious.device_type', :test_default_type)
        @manager.call(@env)
      end

      it "calls the response callback on strategies that have it defined" do
        @env.stub_everything
        @strategy1.stubs(:get_device_type)
        @strategy1.stubs(:respond_to?).with(:response_callback).returns(true)
        @strategy1.expects(:response_callback).with() {|request, response|
          request.must_be_instance_of Rack::Request
          (request.env == @env).must_equal true
          response.must_be_instance_of Rack::Response
          response.body.must_equal @return_value[0]
        }

        @strategy2.stub_everything
        @strategy3.stub_everything
        @manager.call(@env)
      end
    end

    describe "not having strategies" do
      it "uses default value" do
        @app.stub_everything
        Mobvious.config.default_device_type = :test_default_type
        @env.expects('[]=').with('mobvious.device_type', :test_default_type)
        @manager.call(@env)
      end
    end
  end
  end
end
