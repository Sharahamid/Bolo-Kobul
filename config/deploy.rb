## config valid for current version and patch releases of Capistrano
#lock "~> 3.11.2"
#
#set :repo_url,        'git@bitbucket.org:sajid_9185/bolokobul.git'
#set :application,     'bolokobul_stage'
#set :user,            'ubuntu'
#set :puma_threads,    [4, 16]
#set :puma_workers,    0
#
## Don't change these unless you know what you're doing
#set :pty,             true
#set :use_sudo,        false
#set :stage,           :staging
#set :rails_env,       :staging
#set :deploy_via,      :remote_cache
#set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
#set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
#set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
#set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
#set :puma_access_log, "#{release_path}/log/puma.error.log"
#set :puma_error_log,  "#{release_path}/log/puma.access.log"
#set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/bolokobul_pem.pem) }
#set :puma_preload_app, true
#set :puma_worker_timeout, nil
#set :puma_init_active_record, true  # Change to false when not using ActiveRecord
#
#set :rvm_type, :ubuntu
#
### Defaults:
## set :scm,           :git
# set :branch,        :basic_user_profile_info
## set :format,        :pretty
## set :log_level,     :debug
# set :keep_releases, 5
#
### Linked Files & Directories (Default None):
#set :linked_files, %w[config/application.yml config/database.yml config/secrets.yml]
#
#set(
#    :linked_dirs,
#    %w[log tmp/pids tmp/states tmp/sockets tmp/cache vendor/bundle storage]
#)
#
#namespace :puma do
#  desc 'Create Directories for Puma Pids and Socket'
#  task :make_dirs do
#    on roles(:app) do
#      execute "mkdir #{shared_path}/tmp/sockets -p"
#      execute "mkdir #{shared_path}/tmp/pids -p"
#    end
#  end
#
#  before :start, :make_dirs
#end
#
namespace :deploy do
  desc "reload the database with seed data"
  task :seed do
    on roles(:app) do
      within release_path do
        execute :bundle, "exec rake db:seed RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end

#  desc "Make sure local git is in sync with remote."
#  task :check_revision do
#    on roles(:app) do
#      unless `git rev-parse HEAD` == `git rev-parse origin/basic_user_profile_info`
#        puts "WARNING: HEAD is not the same as origin/basic_user_profile_info"
#        puts "Run `git push` to sync changes."
#        exit
#      end
#    end
#  end
#
#  desc 'Initial Deploy'
#  task :initial do
#    on roles(:app) do
#      before 'deploy:restart', 'puma:start'
#      invoke 'deploy'
#    end
#  end
#
#  before :starting,     :check_revision
#  after  :finishing,    :compile_assets
#  after  :finishing,    :cleanup
end
