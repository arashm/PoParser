require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'geminabox-release'
GeminaboxRelease.patch(:use_config => true, :remove_release => true)

desc "Generate a benchmark file"
task 'generate_benchmark_file' do
  require_relative 'spec/utils/generate_benchmark_file'
  PoParser::GenerateBenchmarkFile.generate_file(File.expand_path("test/benchmark.po", __dir__), 1500)
end
