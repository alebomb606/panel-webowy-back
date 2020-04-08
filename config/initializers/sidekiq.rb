namespace     = "#{Rails.application.secrets.redis_namespace}_#{Rails.env}"
url           = Rails.application.secrets.redis_url

Sidekiq.configure_server do |config|
  schedule_file = 'config/schedule.yml'

  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end

  config.redis = { url: url, namespace: namespace }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url, namespace: namespace }
end
