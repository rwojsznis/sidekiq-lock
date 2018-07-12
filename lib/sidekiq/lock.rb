require 'sidekiq/lock/container'
require 'sidekiq/lock/middleware'
require 'sidekiq/lock/redis_lock'
require 'sidekiq/lock/version'
require 'sidekiq/lock/worker'

module Sidekiq
  def self.lock_container
    @lock_container ||= Lock::Container.new
  end

  def self.lock_method
    @lock_method ||= Lock::METHOD_NAME
  end

  def self.lock_container=(container)
    @lock_container = container
  end

  def self.lock_method=(method)
    @lock_method = method
  end

  module Lock
    THREAD_KEY = :sidekiq_lock
    METHOD_NAME = :lock
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Lock::Middleware
  end
end
