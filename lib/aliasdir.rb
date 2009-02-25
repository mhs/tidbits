#!/usr/bin/env ruby

require 'etc'
require 'yaml'

def print_help
  puts <<-EOT.gsub(/^\s+\|/, '')
    |Usage: aliasdir <alias_name> [dir]
    |
    |  alias_name - the name of the alias (required)
    |  dir - the directory to make the alias point to or
    |        leave it blank and it will default to current 
    |        directory
    |
    |Examples:
    |  aliasdir foo
    |  aliasdir foo /some/path
    |
    |Installing in your .bashrc in order to use and persist aliases
    |immediately:
    |
    |------------------START BASH SNIPPET---------------------
    |  # ad is for *alias directory*. It creates persistent
    |  # aliases. Type 'ad -h' for help.
    |  function ad
    |  {
    |    ~/.tidbits/lib/aliasdir.rb $@
    |    eval `~/.tidbits/lib/aliasdir.rb --dump`
    |  }
    |  eval `~/.tidbits/lib/aliasdir.rb --dump`
    |------------------END BASH SNIPPET---------------------
    |
    |Author: Zach Dennis (zach.dennis@gmail.com)
    |        http://www.continuousthinking.com
    |        http://www.mutuallyhuman.com
  EOT
end

class Aliases
  FILE = Etc.getpwuid.dir + '/.aliasdir'

  class << self
    def dump
      aliases.to_a.sort_by{ |arr| arr.first }.map{|arr| "alias #{arr.first}='cd #{arr.last}'"}.join(';')
    end
    
    def [](the_alias)
      aliases[the_alias]
    end
  
    def []=(the_alias, target)
      contents = aliases.merge(the_alias => target).to_yaml
      File.open(FILE, 'w') do |file|
        file.write contents
      end
    end
  
    private

    def aliases
      File.exists?(FILE) ? YAML.load(IO.read(FILE)) : Hash.new
    end
  end
end

if ARGV.empty? || %w(-h --help).include?(ARGV.first)
  print_help
elsif ARGV.first == '--dump'
  puts Aliases.dump
elsif ARGV.first == '--spec'
  at_exit{ run_spec }
else
  the_alias = ARGV.shift
  target = ARGV.shift || Dir.pwd
  Aliases[the_alias] = target
end

def run_spec
  ARGV.shift
  require 'rubygems'
  require 'fileutils'
  require 'spec'
  Aliases.class_eval do
    const_set :SPEC_FILE, Etc.getpwuid.dir + '/.aliasdir_spec'
    at_exit { FileUtils.rm(Aliases::FILE) if File.exists?(Aliases::FILE) }
  end

  describe Aliases, '#[]= - aliasing a directory' do
    it 'should store the aliases directory in the Aliases::FILE' do
      Aliases['test'] = '/the/test/directory'
      YAML.load(IO.read(Aliases::FILE))['test'].should == '/the/test/directory'
    end

    it 'should be able to overwrite an alias with a new directory in the Aliases::FILE' do
      Aliases['test'] = '/the/test/directory'
      Aliases['test'] = '/a/new/cool/place'
      YAML.load(IO.read(Aliases::FILE))['test'].should == '/a/new/cool/place'
    end
    
    it 'should be able to store multiple aliases in the Aliases::FILE' do
      Aliases['test1'] = '1'
      Aliases['test2'] = '2'
      aliases = YAML.load(IO.read(Aliases::FILE))
      aliases['test1'].should == '1'
      aliases['test2'].should == '2'
    end
  end
  
  describe Aliases, '#[] - reading an an alias' do
    it 'should be able to return the aliased target path' do
      Aliases['foo'] = 'bar'
      Aliases['foo'].should == 'bar'
    end
  end
  
  describe Aliases, '#dump - dumping aliases for shell execution' do
    before(:each) do
      FileUtils.rm(Aliases::FILE)
      Aliases['blam'] = 'bar'
      Aliases['foo'] = 'baz'
    end
    
    it 'should be able to return the appropriate string of aliases for bash shell execution' do
      Aliases.dump.should == %|alias blam='bar';alias foo='baz'|
    end
  end
end
