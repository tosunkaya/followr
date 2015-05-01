require 'raygun/sidekiq'
Raygun.setup do |config|
  config.api_key = "DNWwyBh6asGKg5e9gMzTCQ=="
  config.filter_parameters = Rails.application.config.filter_parameters
  config.enable_reporting = Rails.env.production? || Rails.env.staging?
end
