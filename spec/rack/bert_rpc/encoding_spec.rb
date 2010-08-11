require 'spec_helper'
require 'bert'

module Rack
  class BertRpc
    describe Encoding do
      subject do
        o = Object.new
        o.extend Encoding
        o
      end

      describe "#read_rpc" do
        it "returns the decoded berp" do
          msg = BERT.encode(t[:call, :mod, :fun, ["blah", 1]])
          input = StringIO.new([msg.length].pack("N") + msg)
          input.rewind
          subject.read_rpc(input).should == t[:call, :mod, :fun, ["blah", 1]]
        end
      end

      describe "#error_response" do
        context "when passed an error message" do
          it "returns an encoded error" do
            error = subject.error_response(:server, "Error!")
            decode(error).should == t[:error, t[:server, 0, "Error!"]]
          end
        end

        context "when passed an error object" do
          it "returns an encoded error with a message and backtrace" do
            e = StandardError.new("blah")
            error = subject.error_response(:user, e)
            decode(error).should ==
              t[:error, t[:user, 0, "StandardError", "blah", e.backtrace]]
          end
        end
      end

      describe "#reply_response" do
        it "returns an encoded reply" do
          reply = subject.reply_response("something")
          decode(reply).should == t[:reply, "something"]
        end
      end

      describe "#noreply_response" do
        it "returns an encoded reply" do
          reply = subject.noreply_response
          decode(reply).should == t[:noreply]
        end
      end

      def decode(berp)
        io = StringIO.new(berp)
        length = io.read(4).unpack("N").first
        BERT.decode(io.read(length))
      end
    end
  end
end
