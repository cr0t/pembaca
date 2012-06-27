require 'bundler/capistrano'
require 'rvm/capistrano'

set :rvm_type, :system
set :rvm_ruby_string, "ree-1.8.7-2011.03@pembaca"

set :application, "com.summercode.pembaca"
set :repository,  "git@github.com:cr0t/pembaca.git"

set :scm, :git
set :branch, "master"

role :app, "pembaca.summercode.com"

set :user, "cr0t"
set :use_sudo, false

set :deploy_to, "/var/www/#{application}"

set :keep_releases, 3

namespace :deploy do
  task :start do
    run "/etc/unicorns/pembaca start"
    run "/etc/unicorns/pembaca_worker start"
  end

  task :stop do
    run "/etc/unicorns/pembaca stop"
    run "/etc/unicorns/pembaca_worker stop"
  end

  task :restart do
    run "/etc/unicorns/pembaca restart"
    run "/etc/unicorns/pembaca_worker restart"
  end

  after "deploy:update" do
    deploy::cleanup
  end
end
