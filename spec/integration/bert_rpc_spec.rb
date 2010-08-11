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

    def decode(berp)
      io = StringIO.new(berp)
      length = io.read(4).unpack("N").first
      BERT.decode(io.read(length))
    end

    it "returns the results of the correct function call" do
      data = berp(BERT.encode(t[:call, :hello, :say_hello, ["Ryan"]]))
      get "/rpc", {}, "rack.input" => StringIO.new(data)
      response = last_response.body
      decode(response).should == t[:reply, "Hello, Ryan!"]
    end

    it "returns an error for bad functions calls" do
      data = berp(BERT.encode(t[:call, :nope, :say_hello, ["Ryan"]]))
      get "/rpc", {}, "rack.input" => StringIO.new(data)
      response = last_response.body
      # I would match more in depth but I can't figure how to match a backtrace
      decode(response).first.should == :error
    end

    it "returns noreply for casts" do
      data = berp(BERT.encode(t[:cast, :nope, :say_hello, ["Ryan"]]))
      get "/rpc", {}, "rack.input" => StringIO.new(data)
      response = last_response.body
      decode(response).should == t[:noreply]
    end
  end
end
