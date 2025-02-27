require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GcamBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    
        # تفعيل Middleware الخاص بالكوكيز وجلسات الكوكيز
        config.middleware.use ActionDispatch::Cookies
        config.middleware.use ActionDispatch::Session::CookieStore, key: '5d281df1e9b19262c392b7ab86434965fe7fc52c6347cd2c74c9b097aec6f8885426555135601513ec49160436e8bc5796d7c3839fb67c5b8f6c4397d68583ebb733298f617105db9412428371450a9dd0fed65929cb63992d155ac69ba5573229fa1775e9bb6b9c629e5ed9bc2efce1b82f339ba6e430a2417e96c1a879a2a366328b214eaf6e9ae719b9df7ed45ea87262a8f6ec00b24a438bf298b5d37efaf6fa4ed63190e888d1e99d5ac893d0abeb5d41d673a93a91ce1ce1b90341', expire_after: 2.hours

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
