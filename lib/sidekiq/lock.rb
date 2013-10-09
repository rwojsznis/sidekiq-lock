require "sidekiq/lock/version"
require "sidekiq/lock/worker"
require "sidekiq/lock/middleware"
require "sidekiq/lock/redis_lock"

module Sidekiq
  module Lock
    THREAD_KEY = :sidekiq_lock
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Lock::Middleware
  end
end
