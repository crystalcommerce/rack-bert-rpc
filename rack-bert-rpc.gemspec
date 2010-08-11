lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rack/bert_rpc/version'

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

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'

  s.files = File.readlines("Manifest.txt").inject([]) do |files, line|
    files << line.chomp
  end
  s.require_path = 'lib'
end
