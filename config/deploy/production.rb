set :username, 'safeway-prod'
set :hostname, '134.209.85.127'
set :rails_env,  'production' # select which RAILS_ENV to set when deploying
set :branch,     'master' # select which branch should be deployed

server fetch(:hostname), user: fetch(:username), roles: %w(web app db), primary: true

set :application, fetch(:username)
set :deploy_to,   "/home/#{fetch(:username)}/www/"
