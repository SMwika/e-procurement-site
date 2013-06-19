require "rvm/capistrano"
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"") # Read from local system
set :rvm_ruby_string, "ruby-1.9.2-p290"
set :rvm_type, :user
before 'deploy', 'rvm:install_rvm'
server "192.168.0.241", :app, :web, :db, :primary => true
set :user, "tigeorgia"
set :deploy_to, "/var/data/procurement/app"
set :use_sudo, false
