require "test_helper"

module Sidekiq
  module Lock
    describe Worker do

      it 'sets lock method that points to thread variable' do
        Thread.current[Sidekiq::Lock::THREAD_KEY] = "test"
        assert_equal "test", LockWorker.new.lock
      end

    end
  end
end
