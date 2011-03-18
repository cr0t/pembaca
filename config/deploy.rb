set :application, "com.summercode.pembaca"

set :scm, :git
set :branch, "master"
set :repository,  "gitosis@git.summercode.com:liberty.git"

role :app, "pembaca.summercode.com"

set :user, "cr0t"
set :use_sudo, false

set :deploy_to, "/var/www/#{application}"

set :keep_releases, 3

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  after "deploy:update" do
    deploy::cleanup
  end
end