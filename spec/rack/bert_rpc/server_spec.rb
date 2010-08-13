require 'spec_helper'

module Rack
  class BertRpc
    describe Server do
      module SampleMod; end

      describe "#expose" do
        it "creates a new Rack::BertRpc::Module wrapping the ruby module" do
          Mod.should_receive(:new).with(SampleMod)
          subject.expose(:sample, SampleMod)
        end

        it "stores the modules based on the key" do
          mod = mock("Rack::BertRpc::Mod")
          Mod.stub(:new).and_return(mod)
          subject.expose(:sample, SampleMod)
          subject.mods[:sample].should == mod
        end
      end

      describe "#handle" do
        let(:input){ mock("Input") }

        it "reads the input" do
          subject.stub(:error_response)
          subject.should_receive(:read_rpc).with(input).and_return([])
          subject.handle(input)
        end

        context "the request is a call" do
          before do
            subject.stub(:read_rpc).and_return([:call, :mod, :fun, ["args"]])
            subject.stub(:reply_response)
          end

          it "calls #dispatch with the mod/fun/args" do
            subject.should_receive(:dispatch).with(:mod, :fun, ["args"])
            subject.handle(input)
          end

          context "there is a server error" do
            let(:error){ ServerError.new }

            before do
              subject.stub(:dispatch).and_raise(error)
            end

            it "calls #error_response with the error data" do
              subject.should_receive(:error_response).with(:server, error)
              subject.handle(input)
            end

            it "returns the response" do
              error = mock("Error response")
              subject.stub(:error_response).and_return(error)
              subject.handle(input).should == error
            end
          end

          context "there is a non-server error" do
            let(:error){ NameError.new }

            before do
              subject.stub(:dispatch).and_raise(error)
            end

            it "calls #error_response with the error data" do
              subject.should_receive(:error_response).with(:user, error)
              subject.handle(input)
            end

            it "returns the response" do
              error = mock("Error response")
              subject.stub(:error_response).and_return(error)
              subject.handle(input).should == error
            end
          end

          context "there is no error" do
            let(:response){ mock("Response") }

            before do
              subject.stub(:dispatch).and_return(response)
            end

            it "responds with a reply" do
              subject.should_receive(:reply_response).with(response)
              subject.handle(input)
            end

            it "has the #dispatch response in the reply" do
              reply = mock("Reply")
              subject.stub(:reply_response).and_return(reply)
              subject.handle(input).should == reply
            end
          end
        end

        context "the request is a cast" do
          before do
            subject.stub(:read_rpc).and_return([:cast, :mod, :fun, ["args"]])
            subject.stub(:noreply_response)
            subject.stub(:dispatch)
          end

          it "calls #dispatch with the mod/fun/args" do
            subject.should_receive(:dispatch).with(:mod, :fun, ["args"])
            subject.handle(input)
          end

          it "responds with a noreply" do
            noreply = mock("No reply")
            subject.stub(:noreply_response).and_return(noreply)
            subject.handle(input).should == noreply
          end
        end

        context "the request is invalid" do
          before do
            subject.stub(:read_rpc).and_return(nil)
          end

          it "calls #error_response with invalid request info" do
            subject.should_receive(:error_response).with(:server,
                                            "Invalid request: unrecognized")
            subject.handle(input)
          end
        end
      end

      describe "#dispatch" do
        context "the mod isn't loaded on this server" do
          it "raises a server error" do
            lambda{ subject.dispatch(:nope, :fun, ["args"]) }.
              should raise_error(ServerError)
          end
        end

        it "calls the function on the mod" do
          mod = mock("Mod")
          subject.mods[:sample] = mod
          mod.should_receive(:call_fun).with(:fun, ["args!", 1])
          subject.dispatch(:sample, :fun, ["args!", 1])
        end
      end
    end
  end
end
