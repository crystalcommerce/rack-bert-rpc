require 'rack'

module Rack
  class BertRpc
    attr_reader :path

    def initialize(app, options = {})
      @path = options[:path] || '/rpc'
      @app = app
      @server = options[:server] || Server.new
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
  end
end

require 'rack/bert_rpc/server'
