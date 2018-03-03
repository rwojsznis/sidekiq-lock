require 'coveralls'
Coveralls.wear! do
  add_filter '/test/'
end

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/setup'

require 'sidekiq'
require 'test_workers'

Sidekiq.logger.level = Logger::ERROR

REDIS = Sidekiq::RedisConnection.create(url: 'redis://localhost/15')

def redis(command, *args)
  Sidekiq.redis do |c|
    c.send(command, *args)
  end
end

def set_lock_variable!(value = nil)
  Thread.current[Sidekiq::Lock::THREAD_KEY] = value
end

def lock_thread_variable
  Thread.current[Sidekiq::Lock::THREAD_KEY]
end
