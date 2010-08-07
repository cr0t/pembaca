# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'resque/tasks'
require 'lib/convert_job'

Liberty::Application.load_tasks

# need to do something with such "dirty configuration hack"
mongoid_conf = YAML::load_file(Rails.root.join('config/mongoid.yml'))[Rails.env]
Resque.mongo = mongoid_conf['host']
