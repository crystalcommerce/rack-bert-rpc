require 'rspec'
require 'rack/test'

$:.unshift '../../lib'
require 'rack/bert_rpc'

RSpec.configure do |c|
  c.include Rack::Test::Methods
end
