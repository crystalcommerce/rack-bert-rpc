module Rack
  class BertRpc
    class Mod
      attr_reader :source_module, :funs
      attr_writer :loaded

      def initialize(source_module)
        @source_module = source_module
        @loaded = false
        @funs = {}
      end

      def call_fun(fun, args)
        unless loaded?
          load_module
        end

        if funs[fun].nil?
          raise(ServerError.new("No such function " +
                                "'#{source_module.name}##{fun}'"))
        end

        funs[fun].call(*args)
      end

      def loaded?
        @loaded
      end

      def load_module
        @context = Object.new
        @context.extend source_module
        source_module.public_instance_methods.each do |meth|
          funs[meth.to_sym] = @context.method(meth)
        end
        self.loaded = true
      end
    end
  end
end
