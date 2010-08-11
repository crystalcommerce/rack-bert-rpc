require 'spec_helper'

module Rack
  class BertRpc
    describe Mod do
      module TestMod
        def foo(x)
          x * 2
        end
      end

      describe "#initialize" do
        it "stores the module" do
          mod = Mod.new(TestMod)
          mod.source_module.should == TestMod
        end
      end

      describe "#call_fun" do
        subject{ Mod.new(TestMod) }

        context "the function doesn't exist" do
          it "raises a server error" do
            lambda{ subject.call_fun(:bar, [80]) }.
              should raise_error(ServerError)
          end
        end

        it "calls the function with the arguments" do
          subject.call_fun(:foo, [18]).should == 36
        end

        context "the module hasn't been loaded" do
          before do
            subject.loaded = false
          end

          it "loads the source module" do
            subject.call_fun(:foo, [1])
            subject.should be_loaded
          end
        end

        context "the modules has been loaded" do
          before do
            subject.load_module
          end

          it "doesn't load the source module" do
            subject.should_not_receive(:load_module)
            subject.call_fun(:foo, [13])
          end
        end
      end
    end
  end
end
