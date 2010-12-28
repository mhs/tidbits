
def colorize(text, color_code); "#{color_code}#{text}\e[0m"; end
def red(text); colorize(text, "\e[31m"); end
def green(text); colorize(text, "\e[32m"); end

require 'rubygems'
require 'yaml'
require 'ruby-debug'
begin
  require 'grit'
  require 'pivotal-tracker'
rescue LoadError
  puts red("Could not load dependencies. Make sure you have the grit and pivotal-tracker gems installed.")
  exit(1)
end

module Gitutils
  def self.pivotal_project
    return @pivotal_project if @pivotal_project
    begin
      PivotalTracker::Client.token = YAML.load_file( File.join(File.dirname(__FILE__), '../config/pivotal.yml'))['api_token']
    rescue Errno::ENOENT
      puts red("Please set up a config/pivotal.yml file. An example is located at config/pivotal.yml.example.")
      exit(1)
    end

    begin
      pivotal_id = YAML.load_file(File.join(Dir.pwd, 'config/pivotal.yml'))['project_id']
    rescue Errno::ENOENT
      puts red("Pivotal Project not configured for this git repo.")
      PivotalTracker::Project.all.each{|p| puts "#{p.id} #{p.name}"}
      puts "\nEnter the Pivotal id for the project:"
      pivotal_id = gets
      File.open(File.join(Dir.pwd, 'config/pivotal.yml'), 'w') do |f|
        YAML.dump({'project_id' => pivotal_id}, f)
      end
    end

    @pivotal_project = PivotalTracker::Project.find pivotal_id
  end

  def self.pivotal_story_id
    topic_branch.scan(/(\d+)_\S+/).flatten.first
  end

  def self.pivotal_story
    @pivotal_story ||= pivotal_project.stories.find pivotal_story_id
  end

  def self.repo
    begin
      @repo ||= Grit::Repo.new(Dir.pwd)
    rescue Grit::InvalidGitRepositoryError
      puts "The current directory is not a git repository."
    end
  end

  def self.topic_branch
    return @topic_branch if @topic_branch
    if repo.head.name =~ /\d+_\S*/
      topic_branch = repo.head.name
    else
      if ARGV.first =~ /\d+_\S*/
        topic_branch = ARGV.first
      else
        puts red "The branch you specified is not a topic branch."
        exit
      end
    end

    @topic_branch = topic_branch
  end

  def self.create_topic_branch
    repo.git.branch({}, topic_branch, "master")
    checkout topic_branch
    repo.git.push({}, "origin", "#{topic_branch}:refs/heads/#{topic_branch}")
    repo.git.fetch({}, "origin")
    repo.git.config({}, "branch.#{topic_branch}.remote", "origin")
    repo.git.config({}, "branch.#{topic_branch}.merge", "refs/heads/#{topic_branch}")
    checkout topic_branch
  end

  def self.merge
    repo.git.merge({}, topic_branch)
  end

  def self.checkout branch
    repo.git.checkout({}, branch)
  end

  def self.destroy_topic_branch
    repo.git.push({}, "origin :#{topic_branch}")
    repo.git.branch({'D' => ''}, topic_branch)
  end

  def self.add_label label
    pivotal_story.labels = (pivotal_story.labels || "").split(",").push(label).join(",")
    pivotal_story.update
    label
  end

  def self.remove_label label
    labels = (pivotal_story.labels.split(",") || [])
    labels.delete(label)
    pivotal_story.labels = labels.join(",")
    pivotal_story.update
    label
  end

  def self.start
    pivotal_story.current_state = "started"
    pivotal_story.update
  end

  def self.accept
    pivotal_story.current_state = "accepted"
    pivotal_story.update
  end
end

Gitutils.topic_branch # must be called before changing branches
