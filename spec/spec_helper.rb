require 'rubygems'
require 'bundler'
Bundler.setup

require 'fileutils'
require 'rspec'
Dir[File.dirname(__FILE__) + "/shared/*.rb"].each{ |f| puts f ; require f }

