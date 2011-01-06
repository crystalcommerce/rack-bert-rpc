# -*- ruby -*-
require 'bundler'
Bundler::GemHelper.install_tasks
Bundler.setup
Bundler.require(:default)

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
