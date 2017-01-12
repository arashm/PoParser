require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'geminabox-release'
GeminaboxRelease.patch(:use_config => true, :remove_release => true)

