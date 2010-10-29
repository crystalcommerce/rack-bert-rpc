require File.expand_path("../lib/rack/bert_rpc/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rack-bert-rpc"
  s.version     = Rack::BertRpc::VERSION
  s.author      = "Ryan Burrows"
  s.email       = "rhburrows@gmail.com"
  s.homepage    = "http://github.com/crystalcommerce/rack-bert-rpc"
  s.summary     = "Rack middleware BERT-RPC server"
  s.description = "rack-bert-rpc is rack middleware that provides a BERT-RPC " +
    "server implemenation for using BERT-RPC over HTTP"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency 'bert'
  s.add_dependency 'rack'

  s.add_development_dependency 'bundler', ">= 1.0.0"
  s.add_development_dependency 'rspec', "~> 2.0.1"
  s.add_development_dependency 'rack-test'

  s.files = File.readlines("Manifest.txt").inject([]) do |files, line|
    files << line.chomp
  end
  s.require_path = 'lib'
end
