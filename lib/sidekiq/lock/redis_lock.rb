module Sidekiq
  module Lock
    class RedisLock
      attr_reader :options, :payload

      # checks for configuration
      def initialize(options, payload)
        @options  = options.symbolize_keys
        @payload  = payload
        @acquired = false

        timeout
        name
      end

      def acquired?
        @acquired
      end

      # acquire lock using modified SET command introduced in Redis 2.6.12
      # this also requires redis-rb >= 3.0.5
      def acquire!
        @acquired ||= Sidekiq.redis do |r|
          r.set(name, value, { nx: true, px: timeout })
        end
      end

      def release!
        Sidekiq.redis do |r|
          begin
            r.evalsha redis_lock_script_sha, keys: [name], argv: [value]
            rescue Redis::CommandError
              r.eval redis_lock_script, keys: [name], argv: [value]
          end
        end
      end

      def name
        raise ArgumentError, "Provide a lock name inside sidekiq_options" if options[:name].nil?

        @name ||= (options[:name].respond_to?(:call) ? options[:name].call(*payload) : options[:name])
      end

      def timeout
        raise ArgumentError, "Provide lock timeout inside sidekiq_options" if options[:timeout].nil?

        @timeout ||= (options[:timeout].respond_to?(:call) ? options[:timeout].call(*payload) : options[:timeout]).to_i
      end

      private

        def redis_lock_script_sha
          @lock_script_sha ||= Digest::SHA1.hexdigest redis_lock_script
        end

        def redis_lock_script
          <<-LUA
          if redis.call("get", KEYS[1]) == ARGV[1]
          then
            return redis.call("del",KEYS[1])
          else
            return 0
          end
          LUA
        end

        def value
          @value ||= SecureRandom.hex(25)
        end
    end
  end
end
