Kaminari.configure do |config|
  config.param_name = 'page[number]'
  config.default_per_page = 10_000
  config.params_on_first_page = true
end
