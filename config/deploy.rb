set :repo_url,     'git@gitlab.com:marcin.lewicki/panel-webowy-back.git'
set :stages,       %w(staging production)

# Files that are not stored in repository. You need to manually create them on server.
set :linked_files, %w(config/database.yml config/unicorn.rb config/secrets.yml)
# Add folders that you want to link. These folders will not be overwritten after the deploy
# because they won't be present in repository.
# For example if you have the uploads folder and you don't want to lose files
# every time you deploy, add this folder here (public/uploads)
set :linked_dirs,  %w(log vendor/bundle tmp/sockets tmp/pids tmp/cache public/temp_videos)

set :keep_releases, 5
set :normalize_asset_timestamps, %(public/images public/javascripts public/stylesheets)
set :format_options, truncate: false

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

set :rvm_ruby_version, '2.6.5@safeway'	# put Ruby version and gemset name here

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 10 do
      execute 'sudo systemctl restart $USER-unicorn.service'
      execute 'sudo systemctl restart $USER-sidekiq.service'
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end
