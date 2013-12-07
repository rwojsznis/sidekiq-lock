module Sidekiq
  module Lock
    module Worker

      def self.included(base)
        base.send(:define_method, Sidekiq.lock_method) do
          Thread.current[Sidekiq::Lock::THREAD_KEY]
        end
      end

    end
  end
end
