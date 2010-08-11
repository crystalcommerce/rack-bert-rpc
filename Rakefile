# -*- ruby -*-
require 'rubygems'

lib = File.expand_path("../lib", __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rack/bert_rpc/version'

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts << '--format specdoc --colour'
  end
rescue LoadError
  task(:spec){ $stderr.puts "`gem install rspec` to run specs." }
end

task :default => :spec

desc 'Build the rack-bert-rpc gem'
task :build do
  system 'gem build rack-bert-rpc.gemspec'
end

desc 'Push the gem to gemcutter'
task :release => :build do
  system "git tag v#{Rack::BertRpc::VERSION}"
  system "git push origin v#{Rack::BertRpc::VERSION}"
  system "gem push rack-bert-rpc-#{Rack::BertRpc::VERSION}.gem"
end

desc 'Clean up old gems'
task :clean do
  system "rm *.gem"
end
