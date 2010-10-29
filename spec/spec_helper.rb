require 'rspec'
require 'rack/test'

$:.unshift '../../lib'
require 'rack/bert_rpc'

require 'support/bert_rpc_matchers.rb'

RSpec.configure do |c|
  c.include Rack::Test::Methods
end
