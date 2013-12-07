require "test_helper"

module Sidekiq
  module Lock
    describe Worker do

      after { clear_lock_variable }

      it 'sets lock method that points to thread variable' do
        Thread.current[Sidekiq::Lock::THREAD_KEY] = "test"
        assert_equal "test", LockWorker.new.lock
      end

      it 'allows method name configuration' do
        Sidekiq.lock_method = :custom_lock_name

        class WorkerWithCustomLockName
          include Sidekiq::Worker
          include Sidekiq::Lock::Worker
        end

        Thread.current[Sidekiq::Lock::THREAD_KEY] = "custom_name"

        assert_equal "custom_name", WorkerWithCustomLockName.new.custom_lock_name
      end

    end
  end
end
