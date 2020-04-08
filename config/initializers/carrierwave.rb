CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     Rails.application.secrets.digital_ocean[:key_id],
    aws_secret_access_key: Rails.application.secrets.digital_ocean[:secret],
    region:                'ams3',
    host:                  'ams3.digitaloceanspaces.com',
    endpoint:              'https://ams3.digitaloceanspaces.com'
  }
  config.fog_directory  = Rails.application.secrets.digital_ocean[:bucket]
  config.fog_public     = false
  config.asset_host     = "https://sternkraft.ams3.digitaloceanspaces.com"
  config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
end
