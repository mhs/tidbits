class ::String
  def strip_eachline
    gsub!(/^\s+/, '')
  end
end

class Gen < Thor

  desc "cucumber", "Make cucumber directory structure in current directory "
  def cucumber
    FileUtils.touch('cucumber.yml')
    FileUtils.mkdir_p('features/support')
    FileUtils.touch('features/support/env.rb')
    FileUtils.mkdir_p('features/step_definitions')
    
    File.open('cucumber.yml', 'w') do |file|
      file.write <<-EOF.strip_eachline
        default: -r features/support -r features/step_definitions
      EOF
    end
    
    File.open('features/support/env.rb', 'w') do |file|
      file.write <<-EOF.strip_eachline
        require 'cucumber'
        require 'cucumber/formatter/unicode'
        require 'spec'
        #require 'webrat'
      EOF
    end
  end

end