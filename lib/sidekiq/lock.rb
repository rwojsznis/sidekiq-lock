require 'sidekiq/lock/middleware'
require 'sidekiq/lock/redis_lock'
require 'sidekiq/lock/version'
require 'sidekiq/lock/worker'

module Sidekiq
  def self.lock_method
    @lock_method ||= :lock
  end

  def self.lock_method=(method)
    @lock_method = method
  end

  module Lock
    THREAD_KEY = :sidekiq_lock
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Lock::Middleware
  end
end
