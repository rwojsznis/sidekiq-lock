require 'test_helper'

module Sidekiq
  module Lock
    describe Worker do
      # after {  }

      class CustomContainer
        def initialize
          @lock = nil
        end

        def fetch
          @lock
        end

        def store(lock)
          @lock = lock
        end
      end

      # it 'sets lock method that points to thread variable' do
      #   set_lock_variable! "test"
      #   assert_equal "test", LockWorker.new.lock
      # end

      it 'allows method name configuration' do
        begin
          Sidekiq.lock_method = :custom_lock_name

          class WorkerWithCustomLockName
            include Sidekiq::Worker
            include Sidekiq::Lock::Worker
          end

          set_lock_variable! "custom_name"

          assert_equal "custom_name", WorkerWithCustomLockName.new.custom_lock_name

          reset_lock_variable!
        ensure

          Sidekiq.lock_method = Sidekiq::Lock::METHOD_NAME
        end
      end

      it 'allows container configuration' do
        begin
          container = CustomContainer.new
          Sidekiq.lock_container = container

          class WorkerWithCustomContainer
            include Sidekiq::Worker
            include Sidekiq::Lock::Worker
          end

          container.store "lock-variable"

          assert_equal "lock-variable", WorkerWithCustomContainer.new.lock
        ensure
          Sidekiq.lock_container = Sidekiq::Lock::Container.new
        end
      end
    end
  end
end
