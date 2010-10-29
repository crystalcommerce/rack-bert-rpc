require 'spec_helper'
require 'bert'
require 'integration/hello_sample'

module Rack
  describe BertRpc do
    def app
      Builder.new do
        use BertRpc, :expose => {
          :hello => HelloSample
        }
        run lambda{ |env| [200, {}, "success"] }
      end
    end

    def berp(msg)
      [msg.length].pack("N") + msg
    end

    it "returns the results of the correct function call" do
      data = berp(BERT.encode(t[:call, :hello, :say_hello, ["Ryan"]]))
      get "/rpc", {}, "rack.input" => StringIO.new(data)
      last_response.should eql_bert(t[:reply, "Hello, Ryan!"])
    end

    it "returns an error for bad functions calls" do
      data = berp(BERT.encode(t[:call, :hello, :error, []]))
      get "/rpc", {}, "rack.input" => StringIO.new(data)
      last_response.should be_a_user_error
    end

    it "returns noreply for casts" do
      data = berp(BERT.encode(t[:cast, :nope, :say_hello, ["Ryan"]]))
      get "/rpc", {}, "rack.input" => StringIO.new(data)
      last_response.should eql_bert(t[:noreply])
    end
  end
end
