Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require "minitest/autorun"
require "minitest/pride"

require "sidekiq"
require "sidekiq-lock"

Sidekiq.logger.level = Logger::ERROR

REDIS = Sidekiq::RedisConnection.create(url: "redis://localhost/15", namespace: "sidekiq_lock_test")

def redis(command, *args)
  Sidekiq.redis do |c|
    c.send(command, *args)
  end
end

class LockWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  sidekiq_options lock: { timeout: 1, name: 'lock-worker' }
end

class RegularWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
end
