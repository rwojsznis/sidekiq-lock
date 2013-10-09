module Sidekiq
  module Lock
    module Worker

      def lock
        Thread.current[Sidekiq::Lock::THREAD_KEY]
      end

    end
  end
end
