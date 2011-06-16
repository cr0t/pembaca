$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, "ree@global"

require "bundler/capistrano"

set :application, "com.summercode.pembaca"

set :scm, :git
set :branch, "master"
set :repository,  "gitosis@git.summercode.com:pembaca.git"

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
