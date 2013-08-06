require 'rubygems'
require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'


namespace :test do

  desc 'Run unit tests'
  Rake::TestTask.new(:unit) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/unit/**/*_test.rb'
    test.verbose = true
  end
end

task :test => %w(test:unit)

task :default => :test
