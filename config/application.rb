# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BackendTest4
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.i18n.default_locale = :fr
    config.i18n.load_path += Dir[File.join('config', 'locales', '**', '*.{rb,yml}')]

    Rails.application.routes.default_url_options[:host] = ENV.fetch('APPLICATION_HOST')
  end
end
