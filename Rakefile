# -*- ruby -*-
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
