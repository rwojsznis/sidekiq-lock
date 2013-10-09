require "test_helper"

module Sidekiq
  module Lock
    describe Middleware do
      before do
        Sidekiq.redis = REDIS
        Sidekiq.redis { |c| c.flushdb }
        Thread.current[Sidekiq::Lock::THREAD_KEY] = nil
      end

      let(:msg)    { {'class' => 'LockWorker', 'args' => []} }
      let(:handler){ Sidekiq::Lock::Middleware.new }

      it 'sets the lock variable for workers with provided lock options' do
        handler.call(LockWorker.new, msg, 'default') do
          true
        end

        assert_kind_of RedisLock, Thread.current[Sidekiq::Lock::THREAD_KEY]
      end

      it 'sets nothing for workers without lock options' do
        handler.call(RegularWorker.new, msg, 'default') do
          true
        end

        assert_nil Thread.current[Sidekiq::Lock::THREAD_KEY]
      end

    end
  end
end
