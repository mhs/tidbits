class ::String
  def strip_eachline
    gsub(/(^\s*$)|(^\s*)/, '')
  end
end

module ProjectTemplateMethods
  include FileUtils
  
  def directory(dir, &block)
    if File.directory?(dir)
      log dir, "(already exists)"
    else
      log dir, "(creating directory)"
      mkdir_p(dir)
    end
    Dir.chdir(dir, &block) if block_given?
  end
  
  def file(file, contents)
    if File.exists?(file)
      log file, "(already exists)"
    else
      log file, "(creating file)"
      touch file
      File.open(file, "w"){ |f| f.write contents }  if contents
    end
  end
  
  def log(path, message)
    path = path += '/' if File.directory?(path) && path !~ /\/$/
    puts "#{relativize(path)} #{message}"
  end
  
  def relativize(path)
    File.expand_path(path).gsub(@project_dir, '')
  end
  
  def project(dir, &block)
    @project_dir = File.expand_path(dir) + '/'
    yield
    @project_dir = nil
  end
end


class Gen < Thor
  include ProjectTemplateMethods

  desc "cucumber", "Make cucumber directory structure in current directory"
  def cucumber
    project Dir.pwd do
      file 'cucumber.yml', <<-EOS.strip_eachline
        default: -r features/support -r features/step_definitions
      EOS

      directory 'features' do
        directory 'step_definitions'
        directory 'support' do
          file 'env.rb', <<-EOF.strip_eachline
            require 'cucumber'
            require 'cucumber/formatter/unicode'
            require 'spec'
            #require 'webrat'
          EOF
        end
      end
    end
  end
  
  desc "rspec", "Make rspec directory structure in current directory"
  def rspec
    project Dir.pwd do
      directory "spec" do
        file "spec_helper.rb", <<-EOF.strip_eachline
          require 'spec'
        
          # gem install redgreen for colored test output
          begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end
        
          Spec::Runner.configure do |config|
            # spec config goes here
          end
        EOF
      end
    end
  end
end

