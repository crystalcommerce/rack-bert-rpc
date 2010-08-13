require 'rack/bert_rpc/mod'
require 'rack/bert_rpc/encoding'
require 'rack/bert_rpc/server_error'

module Rack
  class BertRpc
    class Server
      include Encoding

      attr_reader :mods

      def initialize
        @mods = {}
      end

      def expose(sym, mod)
        mods[sym] = Mod.new(mod)
      end

      def handle(input)
        rpc = read_rpc(input)
        if rpc.nil?
          return error_response(:server, "Invalid request: unrecognized")
        end

        if rpc.size == 4 && rpc[0] == :call
          begin
            resp = dispatch(*rpc[1..3])
            reply_response(resp)
          rescue ServerError => e
            error_response(:server, e)
          rescue Object => e
            error_response(:user, e)
          end
        elsif rpc.size == 4 && rpc[0] == :cast
          begin
            dispatch(*rpc[1..3])
          rescue Object => e
            # Just ignore errors here
          end
          noreply_response
        else
          error_response(:server, "Invalid request: #{rpc.inspect}")
        end
      end

      def dispatch(mod, fun, args)
        if mods[mod].nil?
          raise(ServerError.new("No such module '#{mod}'"))
        end

        mods[mod].call_fun(fun, args)
      end
    end
  end
end
