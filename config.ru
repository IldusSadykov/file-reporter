# config.ru
require "./app"
require "sidekiq"
require "sidekiq/web"

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{ENV["REDIS_HOST"]}:#{ENV["REDIS_PORT"]}" }
end

run Rack::URLMap.new("/" => App, "/sidekiq" => Sidekiq::Web)
