#!/usr/bin/env ruby

=begin
This script relies on the "git cherry" command. It reports the commits from all local
branches which have not been merged into an upstream branch. Yellow
=end

require 'rubygems'

gem 'term-ansicolor', '=1.0.3'
require 'term/ansicolor'

class GitCommit
  attr_reader :content
  
  def initialize(content)
    @content = content
  end
  
  def sha
    @content.split[1]
  end

  def to_s
    `git log --pretty=format:"%h %ad %an - %s" #{sha}~1..#{sha}`
  end
  
  def unmerged?
    content =~ /^\+/
  end
  
  def equivalent?
    content =~ /^\-/
  end
end

class GitBranch
  attr_reader :name, :commits
  
  def initialize(name, commits)
    @name = name
    @commits = commits
  end
  
  def unmerged_commits
    commits.select{ |commit| commit.unmerged? }
  end

  def equivalent_commits
    commits.select{ |commit| commit.equivalent? }
  end

end

class GitBranches < Array
  def self.local_branches
    `git branch`.split(/\n/).map{ |e| e.strip.gsub(/\*\s+/, '') }.reject{ |branch| branch =~ /\b#{Regexp.escape(UPSTREAM)}\b/ }.sort
  end
  
  def self.load
    branches = new
    local_branches.each do |branch|
      raw_commits = `git cherry -v #{UPSTREAM} #{branch}`.split(/\n/).map{ |c| GitCommit.new(c) }
      branches << GitBranch.new(branch, raw_commits)
    end
    branches
  end
  
  def unmerged
    reject{ |branch| branch.commits.empty? }.sort_by{ |branch| branch.name }
  end
end

class GitUnmerged
  include Term::ANSIColor
  
  attr_reader :branches

  def initialize(args)
    @options = {}
    extract_options_from_args(args)
  end
  
  def load
    @branches ||= GitBranches.load 
  end
  
  def print_overview
    load
    puts "The following branches possibly have commits not merged to #{UPSTREAM}:"
    branches.unmerged.each do |branch|
      num_unmerged = yellow(branch.unmerged_commits.size.to_s)
      num_equivalent = green(branch.equivalent_commits.size.to_s)
      puts %|  #{branch.name} (#{num_unmerged}/#{num_equivalent} commits)|
    end
  end
  
  def print_help
    puts <<-EOT.gsub(/^\s+\|/, '')
      |Usage: #{$0} [<upstream_branch>|--help|-h]
      |
      |This script relies on the "git cherry" command. It reports the commits from all local
      |branches which have not been merged into an upstream branch. 
      |
      |  #{yellow("yellow")} commits have not been merged
      |  #{green("green")} commits have equivalent changes in <upstream> but different SHAs
      |
      |The default upstream is 'master'. 
      |
      |EXAMPLE: check for all unmerged commits
      |  #{$0}
      |
      |EXAMPLE: check for all unmerged commits and merged commits (but with a different SHA)
      |  #{$0} -a
      | 
      |EXAMPLE: use a different upstream than master
      |  #{$0} --upstream otherbranch
      |
      |Author: Zach Dennis <zdennis@mutuallyhuman.com>
    EOT
    exit
  end
    
  def print_specifics
    load
    puts "Here's a breakdown of the commits for each branch. There is a legend at the very bottom of the output"
    branches.each do |branch|
      puts
      print "#{branch.name}:"
      if branch.unmerged_commits.empty? && !show_equivalent_commits?
        print "(no umerged commits, must have merged commits with different SHAs)\n" 
      else
        puts
      end
      branch.unmerged_commits.each { |commit| puts yellow(commit.to_s) }
  
      if show_equivalent_commits?
        branch.equivalent_commits.each do |commit|
          puts green(commit.to_s)
        end
      end
    end
  end
  
  def print_legend
    load
    puts "" + yellow("yellow") + " commits have not been merged"
    puts "" + green("green") + " commits have equivalent changes in #{UPSTREAM} but different SHAs" if show_equivalent_commits?
  end
  
  def show_help? ; @options[:show_help] ; end
  def show_equivalent_commits? ; @options[:show_equivalent_commits] ; end

  def upstream
    @options[:upstream] || "master"
  end
  
  private
  
  def extract_options_from_args(args)
    @options[:show_help] = true if args.include?("-h") || args.include?("--help")
    @options[:show_equivalent_commits] = true if args.include?("-a")
    if index=args.index("--upstream")
      @options[:upstream] = args[index+1]
    end
  end
end


unmerged = GitUnmerged.new ARGV
UPSTREAM = unmerged.upstream
if unmerged.show_help?
  unmerged.print_help
  exit
else
  unmerged.print_overview
  puts
  unmerged.print_specifics
  puts
  unmerged.print_legend
end
