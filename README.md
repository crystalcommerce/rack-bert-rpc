rack-bert-rpc
=============

rack-bert-rpc a Rack middleware BERT-RPC Server
implementation. HTTP requests matching the specified path are
intercepted by the middleware and interpreted as BERT-RPC requests.

For more information about the BERT-RPC specification go to
[bert-rpc.org](http://bert-rpc.org).

rack-bert-rpc varies from other BERT-RPC server implementations in
that it requires the requests to be made over HTTP. This increases the
complexity and size of the requests, but allows for them to be handled
by the same server that is serving a web application. For this reason
services exposed through rack-bert-rpc cannot be called using
traditional BERT-RPC libraries such as
[bertrpc](http://github.com/mojombo/bertrpc)

Currently rack-bert-rpc only supports the following BERT-RPC features:

* `call` requests
* `cast` requests

The design and implementation of rack-bert-rpc derives heavily from
[ernie](http://github.com/mojombo/ernie)

Installation
------------

    $ [sudo] gem install rack-bert-rpc

Usage
-----

Install rack-bert-rpc as part of your application's middleware stack.

    use Rack::BertRpc, :expose => {
      :mod => Mod
    }

The `BertRpc` middle takes several configuration parameters:

* `expose`
  Takes a `Hash` of module name to actual module
* `path`
  Any requests coming in to this path will be handled as RPC
  requests. Defaults to '/rpc'
* `server`
  Used for testing, switches out the backend `BertRpc::Server` so the
  requests can be handled by a different one

Modules can also be exposed through class level methods on
`Rack::BertRpc`. For example:

    Rack::BertRpc.expose(:mod, Mod)

exposes the module `Mod` as `:mod`. This list of exposed modules can
be cleared using `Rack::BertRpc#clear_exposed`. Note: this will only
clear modules listed through `Rack::BertRpc#expose`, not those exposed
through the Rack configuration.

Example
-------

First define a module containing the function that you want to call:

    module HelloWorld
      def say_hello(name)
        "Hello, #{name}!"
      end
    end

Next in your application's `config.ru` install rack-bert-rpc and
expose the `HelloWorld` module

    require 'rack/bert_rpc'
    require 'hello_world'

    use Rack::BertRpc, :expose => {
      :hello => HelloWorld
    }
    run lambda{ |env| [200, {}, "success"] }

Since we are calling BERT-RPC over HTTP we can't use the default
`bertrpc` gem. Instead here's a sample script to send a BERT-RPC
request over HTTP to test our module

    require 'bert'
    require 'net/http'

    def encode(msg)
      m = BERT.encode(msg)
      [m.length].pack('N') + m
    end

    def decode(msg)
      io = StringIO.new(body)
      length = io.read(4).unpack('N').first
      BERT.decode(io.read(length))
    end

    req = Net::HTTP::Post.new('/rpc')
    req.body = encode(t[:call, :hello, :say_hello, ["Ryan"]])
    resp = nil
    Net::HTTP.start('localhost', 3001){ |http| resp = http.request(req) }

    puts decode(resp.body)[1]

Next start up your rack server on the appropriate port

    $ rackup -p 3001 config.ru

And finally run the script to make the BERT-RPC request

    $ ruby -rubygems call_bert.rb
    Hello, Ryan!

Contribute
---------

If you'd like to contribue to rack-bert-rpc fork the project on
GitHub:

    http://github.com/crystalcommerce/rack-bert-rpc

When your changes are ready, push the code to GitHub and send us a
pull request.
