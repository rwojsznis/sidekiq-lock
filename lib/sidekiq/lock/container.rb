module Sidekiq
  module Lock
    class Container
      THREAD_KEY = :sidekiq_lock

      def fetch
        Thread.current[THREAD_KEY]
      end

      def store(lock)
        Thread.current[THREAD_KEY] = lock
      end
    end
  end
end
