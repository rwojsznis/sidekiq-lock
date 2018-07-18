module Sidekiq
  module Lock
    module Worker
      def self.included(base)
        base.send(:define_method, Sidekiq.lock_method) do
          Sidekiq.lock_container.fetch
        end
      end
    end
  end
end
