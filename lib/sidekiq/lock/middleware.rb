module Sidekiq
  module Lock
    class Middleware
      def call(worker, msg, _queue)
        options = lock_options(worker)
        setup_lock(options, msg['args']) unless options.nil?

        yield
      end

      private

      def setup_lock(options, payload)
        Sidekiq.lock_container.store(RedisLock.new(options, payload))
      end

      def lock_options(worker)
        worker.class.get_sidekiq_options['lock']
      end
    end
  end
end
