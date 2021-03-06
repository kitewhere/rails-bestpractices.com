require File.expand_path('../boot', __FILE__)

require 'rails/all'

module Compass
  RAILS_LOADED = true
end

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module RailsBestpracticesCom
  class Application < Rails::Application
    config.app_generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture => false, :views => false
      g.fixture_replacement :factory_girl
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    config.autoload_paths += %W( #{config.root}/lib #{config.root}/app/sweepers )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.sass.load_paths << "#{Gem.loaded_specs['compass'].full_gem_path}/frameworks/compass/stylesheets"

    MEMCACHE_YAML = Rails.root.join('config', 'memcache.yml')
    MEMCACHE_CONFIG = YAML.load_file(MEMCACHE_YAML)[Rails.env]
    config.cache_store = :dalli_store, *MEMCACHE_CONFIG.delete("hosts"), MEMCACHE_CONFIG
  end
end

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # Reset Rails's object cache
    # Only works with DalliStore
    Rails.cache.reset if forked

    # Reset Rails's session store
    # If you know a cleaner way to find the session store instance, please let me know
    # ObjectSpace.each_object(ActionDispatch::Session::DalliStore) { |obj| obj.reset }
  end
end
