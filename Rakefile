require 'rake'
require 'rspec/core/rake_task'

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec) do |t|
  # t.rspec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.pattern = 'spec/*_spec.rb'
end

task :default => :spec
task :cruise => :spec
