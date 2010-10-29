require 'rack/bert_rpc/mod'
require 'rack/bert_rpc/encoding'
require 'rack/bert_rpc/server_error'

module Rack
  class BertRpc
    class Server
      include Encoding

      attr_reader :mods

      def initialize(logger = nil)
        @logger = logger
        @mods = {}
      end

      def expose(sym, mod)
        mods[sym] = Mod.new(mod)
      end

      def handle(input)
        rpc = read_rpc(input)
        if rpc.nil?
          @logger.error("Invalid rpc request received: '#{input.inspect}'")
          return error_response(:server, "Invalid request: unrecognized")
        end

        if rpc.size == 4 && rpc[0] == :call
          begin
            @logger.debug("RPC Call: '#{rpc.inspect}'")
            resp = dispatch(*rpc[1..3])
            reply_response(resp)
          rescue ServerError => e
            @logger.error("Server error encountered on call: '#{e.inspect}'")
            error_response(:server, e)
          rescue Object => e
            @logger.info("error encountered on call: '#{e.inspect}'")
            error_response(:user, e)
          end
        elsif rpc.size == 4 && rpc[0] == :cast
          begin
            @logger.debug("RPC Call: '#{rpc.inspect}'")
            dispatch(*rpc[1..3])
            noreply_response
          rescue ServerError => e
            @logger.error("Server error encountered on cast: '#{e.inspect}'")
            error_response(:server, e)
          rescue Object => e
            @logger.debug("error encountered on cast: '#{e.inspect}'")
            noreply_response
          end
        else
          @logger.fatal("Unexpected error: '#{e.inspect}'")
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
