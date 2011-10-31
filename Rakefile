require "rubygems"
require "bundler/setup"

require 'rspec/core/rake_task'
require "cucumber/rake/task"

Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ["features"]
end

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb"
end

task :default => [:spec, :cucumber]
