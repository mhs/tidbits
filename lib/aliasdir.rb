#!/usr/bin/env ruby

require 'etc'
require 'yaml'
require File.expand_path(File.join File.dirname(__FILE__), 'aliasdir/aliases.rb')

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


if ARGV.empty?
  puts Aliases.dump(:pretty)
  puts
  puts "See #{$0} -h for more options."
elsif %w(-h --help).include?(ARGV.first)
  print_help
elsif ARGV.first == '--dump'
  puts Aliases.dump(:shell)
elsif ARGV.first == '--spec'
  at_exit{ run_spec }
elsif ARGV.first == '--remove'
  puts Aliases.remove(ARGV[1])
else
  the_alias = ARGV.shift
  # Use shell expansion because Dir.pwd doesn't work with symlinks properly
  target = ARGV.shift || `pwd`.chomp
  Aliases[the_alias] = target
end
