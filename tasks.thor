class ::String
  def format
    md = self.match(/^\s+/)
    offset = md.offset(0)[1]
    gsub(/^.{#{offset}}/, '')
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
      file 'cucumber.yml', <<-EOS.format
        default: -r features/support -r features/step_definitions
      EOS

      directory 'features' do
        directory 'step_definitions'
        directory 'support' do
          file 'env.rb', <<-EOF.format
            require 'cucumber'
            require 'cucumber/formatter/unicode'
            require 'spec'
            #require 'webrat'
          EOF
        end
      end
    end
  end
  
  desc "rakefile", "Make cookie-cutter Rakefile in current directory"
  def rakefile
    project Dir.pwd do
      file "Rakefile", <<-EOT.format
        require 'rake/rdoctask'
        require 'spec'
        require 'spec/rake/spectask'

        desc "Run all specs in spec directory"
        Spec::Rake::SpecTask.new do |t|
          t.spec_opts = ['--options', "\#{File.dirname(__FILE__)}/spec/spec.opts"]
          t.spec_files = FileList['spec/**/*_spec.rb']
        end

        desc "Run all specs in spec directory with RCov"
        Spec::Rake::SpecTask.new(:rcov) do |t|
          t.spec_opts = ['--options', "\#{File.dirname(__FILE__)}/spec/spec.opts"]
          t.spec_files = FileList['spec/**/*_spec.rb']
          t.rcov = true
          t.rcov_opts = lambda do
            IO.readlines(File.dirname(__FILE__) + "/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
          end
        end
        
        desc "Generate RDoc"
        task :docs => :clobber_docs do
          system "hanna --title '#{File.basename(Dir.pwd)} API Documentation'"
        end

        desc "Run specs using jruby"
        task "spec:jruby" do
          result = system "jruby -S rake spec"
          raise "JRuby tests failed" unless result
        end

        desc "Run each spec in isolation to test for dependency issues"
        task :spec_deps do
          Dir["spec/**/*_spec.rb"].each do |test|
            if !system("spec \#{test} &> /dev/null")
              puts "Dependency Issues: \#{test}"
            end
          end
        end
      
        task :default => :spec
      EOT
    end
  end

  
  desc "rspec", "Make rspec directory structure in current directory"
  def rspec
    project Dir.pwd do
      directory "spec" do
        file "rcov.opts", <<-RCOVOPTS.format
          -x gems,spec
        RCOVOPTS
        
        file "spec.opts", <<-SPECOPTS.format
          --diff
          --color
        SPECOPTS
        
        file "spec_helper.rb", <<-EOF.format
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

