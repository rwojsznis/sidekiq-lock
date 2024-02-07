require 'test_helper'

module Sidekiq
  module Lock
    describe Middleware do
      before do
        if Sidekiq::VERSION >= '7'
          Sidekiq.configure_server do |config|
            config.redis = { url: REDIS_URL }
          end
        else
          Sidekiq.redis = REDIS
        end
        Sidekiq.redis { |c| c.flushdb }
        reset_lock_variable!
      end

      it 'sets lock variable with provided static lock options' do
        handler = Sidekiq::Lock::Middleware.new
        handler.call(LockWorker.new, { 'class' => LockWorker, 'args' => [] }, 'default') do
          true
        end

        assert_kind_of RedisLock, lock_container_variable
      end

      it 'sets lock variable with provided dynamic options' do
        handler = Sidekiq::Lock::Middleware.new
        handler.call(DynamicLockWorker.new, { 'class' => DynamicLockWorker, 'args' => [1234, 1000] }, 'default') do
          true
        end

        assert_equal "lock:1234", lock_container_variable.name
        assert_equal 2000, lock_container_variable.timeout
      end

      it 'sets nothing for workers without lock options' do
        handler = Sidekiq::Lock::Middleware.new
        handler.call(RegularWorker.new, { 'class' => RegularWorker, 'args' => [] }, 'default') do
          true
        end

        assert_nil lock_container_variable
      end
    end
  end
end
