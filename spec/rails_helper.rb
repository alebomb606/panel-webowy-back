require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'action_cable/testing/rspec'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'

  SimpleCov.start 'rails' do
    add_group  'Commands',    'app/commands'
    add_group  'Services',    'app/services'
    add_group  'Queries',     'app/queries'
    add_group  'Policies',    'app/policies'
    add_group  'Serializers', 'app/serializers'

    add_filter '/app/error_objects'
    add_filter '/app/models'
    add_filter '/app/exceptions'
    add_filter '/app/controllers/overrides'
    add_filter '/app/controllers/users'
    add_filter '/app/controllers/master_admins/custom_routes_controller.rb'
    add_filter '/app/commands/route_log/import_from_gpx.rb'
  end

  Rails.application.eager_load!
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include ResponseHelper
  config.include RequestHelper
  config.include ConnectionStubs
  config.include RSpec::JsonExpectations::Matchers

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, :type => type
    config.include ::Rails::Controller::Testing::TemplateAssertions, :type => type
    config.include ::Rails::Controller::Testing::Integration, :type => type
  end

  config.include Devise::Test::ControllerHelpers, type: :controller

  Geocoder.configure(lookup: :test)
  Geocoder::Lookup::Test.set_default_stub(
    [
      {
        'coordinates'  => [40.7143528, -74.0059731],
        'address'      => 'Paris, Paris, France',
        'city'         => 'Paris',
        'state'        => 'Paris',
        'country'      => 'France',
        'country_code' => 'FR'
      }
    ]
  )

  Fog.mock!
  connection = Fog::Storage.new(
    provider: 'AWS',
    aws_access_key_id:     Rails.application.secrets.digital_ocean[:key_id],
    aws_secret_access_key: Rails.application.secrets.digital_ocean[:secret],
    region:                'ams3',
    host:                  'ams3.digitaloceanspaces.com',
    endpoint:              'https://ams3.digitaloceanspaces.com'
  )
  connection.directories.create(key: 'sternkraft')
end

JSONAPI::Rails.configure do |config|
  config.logger.level = :warn
end

JSONAPI::Rails.configure do |config|
  config.logger.level = :warn
end
