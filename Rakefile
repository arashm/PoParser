require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'geminabox-release'
GeminaboxRelease.patch(:use_config => true, :remove_release => true)

desc "Generate a random po file"
task 'generate_random_pofile' do
  require_relative 'spec/utils/random_pofile_generator'
  PoParser::RandomPoFileGenerator.generate_file(File.expand_path("test/benchmark.po", __dir__), 1000)
end
