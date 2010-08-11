require 'rubygems'
require 'spec'
require 'rack/test'

$:.unshift '../../lib'

require 'rack/bert_rpc'

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
end
