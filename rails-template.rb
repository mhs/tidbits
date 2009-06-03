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
git :add => '.'
git :commit => "-am 'Initial Commit'"
