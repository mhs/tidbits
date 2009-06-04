project_name = File.basename(root)

run "rm README"
run "rm config/database.yml"
run "rm log/*"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/images/rails.png"
run "rm -rf test"

file "config/database.yml.example", <<-END
development:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{project_name}_development
  pool: 5
  username: root
  password:

test:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{project_name}_test
  pool: 5
  username: root
  password:
END
run "cp config/database.yml.example config/database.yml"

run "capify ."

# TODO: Can we make this pull down the latest release instead of master? Maybe we should add them as gems? (some need to be in environments/test.rb)
plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git'
plugin 'cucumber', :git => 'git://github.com/aslakhellesoy/cucumber.git'
plugin 'webrat', :git => 'git://github.com/brynary/webrat.git'
plugin 'caching_presenter', :git => 'git://github.com/mhs/caching_presenter.git'
plugin 'mhs_deployment', :git => 'git://github.com/mvanholstyn/mhs_deployment.git'

rake "rails:freeze:gems"

generate "rspec"
generate "cucumber"
generate "mhs_deployment"

repository = ask("What repository will this be deployed from?")
server = ask("What host will this be deployed to?")
file "config/deploy.rb", <<-END
set :application, "#{project_name}"
set :repository, "#{repository}"
set :server, "#{server}"
END

git :init
file '.gitignore', <<-END
.DS_Store
/config/database.yml
/db/schema.rb
/log
/tmp
END
# TODO: Maybe this can add the repository as a remote if it doesn't already exist?
git :add => '.'
git :commit => "-am 'Initial Commit'"

__END__

Here are some other resources and examples of things this can do

# http://github.com/jeremymcanally/rails-templates/tree/master/
# http://gist.github.com/33337
# http://github.com/imajes/rails-template/tree/master
# http://ramblingsonrails.com/how-to-use-the-new-templates-in-rails
# http://github.com/ryanb/rails-templates/tree/master

if yes?("Freeze rails gems?")
  # do something
end

route "map.login '/login', :controller => 'sessions', :action => 'new'"

rakefile("cruise_controle.rake") do
  <<-TASK
    desc "Run all the tests, including API and acceptance tests"
    task :cruise do
      Rake::Task['db:migrate'].invoke
      Rake::Task['spec'].invoke
      Rake::Task['spec:stories'].invoke
      Rake::Task['metrics:all'].invoke
      Rake::Task['flogger:record'].invoke
    end
  TASK
end

task :thing do
  # blah
end

initializer 'form_builder.rb', <<-CODE
  ActionView::Base.default_form_builder = SemanticFormBuilder
CODE

rake "db:migrate", :env => 'production'

lib lib_name, <<-CODE
  class Shiny
  end
CODE

inside('vendor') { 
  # do stuff inside the vendor folder
}

plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git', :submodule => true
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
gem "haml", :git => "git://github.com/nex3/haml.git"
rake "gems:install", :sudo => true

git :submodule => "init"