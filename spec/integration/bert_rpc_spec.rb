require 'spec_helper'
require 'bert'
require 'integration/hello_sample'

module Rack
  describe BertRpc do
    class NilLogger
      [:debug, :info, :warn, :error, :fatal].each do |m|
        define_method(m) do |msg|
          nil
        end
      end
    end

    def app
      Builder.new do
        use BertRpc, :expose => {
          :hello => HelloSample
        }, :logger => NilLogger.new
        run lambda{ |env| [200, {}, "success"] }
      end
    end

    def make_request(bert)
      msg = BERT.encode(bert)
      data = [msg.length].pack("N") + msg
      get "/rpc", {}, "rack.input" => StringIO.new(data)
    end

    it "returns the results of the correct function call" do
      make_request(t[:call, :hello, :say_hello, ["Ryan"]])
      last_response.should eql_bert(t[:reply, "Hello, Ryan!"])
    end

    it "returns a user error for errors on calls" do
      make_request(t[:call, :hello, :error, []])
      last_response.should be_a_user_error
    end

    it "returns a server error for bad functions on calls" do
      make_request(t[:call, :nope, :error, []])
      last_response.should be_a_server_error
    end

    it "returns noreply for valid casts" do
      make_request(t[:cast, :hello, :say_hello, ["Ryan"]])
      last_response.should eql_bert(t[:noreply])
    end

    it "returns noreply for errors on casts" do
      make_request(t[:cast, :hello, :error, []])
      last_response.should eql_bert(t[:noreply])
    end

    it "returns a server error for bad functions on casts" do
      make_request(t[:cast, :nope, :error, []])
      last_response.should be_a_server_error
    end
  end
end
