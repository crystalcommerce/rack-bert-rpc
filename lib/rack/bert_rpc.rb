require 'rack'

module Rack
  class BertRpc
    class << self
      def expose(sym, mod)
        exposed_modules << [sym, mod]
      end

      def exposed_modules
        @exposed_modules ||= []
      end

      def clear_exposed
        @exposed_modules = []
      end
    end

    attr_reader :path

    def initialize(app, options = {})
      @path = options[:path] || '/rpc'
      @app = app
      @server = options[:server] || Server.new

      expose_defaults!
      options[:expose].each do |sym, mod|
        @server.expose(sym, mod)
      end unless options[:expose].nil?
    end

    def call(env)
      if path == env["PATH_INFO"]
        response = @server.handle(env["rack.input"])
        [200, { "Content-Type" => "application/bert" }, response]
      else
        @app.call(env)
      end
    end

    private

    def expose_defaults!
      BertRpc.exposed_modules.each do |sym, mod|
        @server.expose(sym, mod)
      end
    end
  end
end

require 'rack/bert_rpc/server'
