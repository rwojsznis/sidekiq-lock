require 'test_helper'

module Sidekiq
  module Lock
    describe Worker do
      after { set_lock_variable! }

      it 'sets lock method that points to thread variable' do
        set_lock_variable! "test"
        assert_equal "test", LockWorker.new.lock
      end

      it 'allows method name configuration' do
        Sidekiq.lock_method = :custom_lock_name

        class WorkerWithCustomLockName
          include Sidekiq::Worker
          include Sidekiq::Lock::Worker
        end

        set_lock_variable! "custom_name"

        assert_equal "custom_name", WorkerWithCustomLockName.new.custom_lock_name
      end

    end
  end
end
