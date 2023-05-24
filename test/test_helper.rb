require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/setup'

require 'sidekiq'
require 'test_workers'

Sidekiq.logger.level = Logger::ERROR

REDIS_URL = 'redis://localhost/15'
REDIS = Sidekiq::RedisConnection.create(url: REDIS_URL)

def redis(command, *args)
  Sidekiq.redis do |c|
    c.send(command, *args)
  end
end

def set_lock_variable!(value)
  Sidekiq.lock_container.store(value)
end

def reset_lock_variable!
  set_lock_variable!(nil)
end

def lock_container_variable
  Sidekiq.lock_container.fetch
end
