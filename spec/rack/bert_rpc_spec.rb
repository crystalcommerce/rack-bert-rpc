require 'spec_helper'
require 'singleton'

module Rack
  describe BertRpc do
    class DummyApp
      include Singleton

      def call(env)
        [200, {}, "success"]
      end
    end

    let(:server){ mock("Rack::BertRpc::Server").as_null_object }

    def app
      s = server
      Builder.new do
        use BertRpc, :path => '/rpc_test', :server => s
        run DummyApp.instance
      end
    end

    describe "#initialize" do
      it "sets the path if specified" do
        middleware = BertRpc.new(nil, :path => '/blah' )
        middleware.path.should == '/blah'
      end

      it "sets the path to '/rpc' if not specified" do
        middleware = BertRpc.new(nil)
        middleware.path.should == '/rpc'
      end

      it "creates a new bert-rpc server" do
        BertRpc::Server.should_receive(:new)
        middleware = BertRpc.new(nil)
      end

      it "exposes the passed modules" do
        server.should_receive(:expose).with(:dummy, DummyApp)
        BertRpc.new(nil, :server => server, :expose => {
                      :dummy => DummyApp
                    })
      end

      it "exposes any modules that have been set as exposed on the class" do
        server.should_receive(:expose).with(:class_level, DummyApp)
        BertRpc.expose(:class_level, DummyApp)
        BertRpc.new(nil, :server => server)
        BertRpc.clear_exposed
      end
    end

    describe "#call" do
      context "when the request path matches the rpc path" do
        it "doesn't pass the request on through the chain" do
          DummyApp.instance.should_not_receive(:call)
          get '/rpc_test'
        end

        it "calls #handle on the server with the request body input stream" do
          server.should_receive(:handle).and_return(StringIO.new)
          get '/rpc_test'
        end
      end

      context "when the request path doesn't match the rpc path" do
        it "passes the request on through the chain" do
          DummyApp.instance.should_receive(:call).and_return([200, {}, "success"])
          get '/something'
        end
      end
    end
  end
end
