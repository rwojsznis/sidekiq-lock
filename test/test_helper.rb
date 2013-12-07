require 'coveralls'
Coveralls.wear!

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require "minitest/autorun"
require "minitest/pride"

require "sidekiq"
require "sidekiq-lock"
require "test_workers"

Sidekiq.logger.level = Logger::ERROR

REDIS = Sidekiq::RedisConnection.create(url: "redis://localhost/15", namespace: "sidekiq_lock_test")

def redis(command, *args)
  Sidekiq.redis do |c|
    c.send(command, *args)
  end
end

def clear_lock_variable
  Thread.current[Sidekiq::Lock::THREAD_KEY] = nil
end
