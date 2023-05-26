require 'test_helper'

module Sidekiq
  module Lock
    describe RedisLock do
      before do
        if Sidekiq::VERSION >= '7'
          Sidekiq.configure_client do |config|
            config.redis = { url: REDIS_URL }
          end
        else
          Sidekiq.redis = REDIS
        end
        Sidekiq.redis { |c| c.flushdb }
      end

      it "raises an error on missing timeout&name values" do
        assert_raises ArgumentError do
          RedisLock.new({},[])
        end
      end

      it "raises an error on missing timeout value" do
        assert_raises ArgumentError do
          RedisLock.new({ 'name' => 'this-is-lock' }, [])
        end
      end

      it "raises an error on missing name value" do
        assert_raises ArgumentError do
          RedisLock.new({ 'timeout' => 500 }, [])
        end
      end

      it "does not raise an error when timeout and name is provided" do
        assert RedisLock.new({ 'timeout' => 500, 'name' => 'lock-name' }, [])
      end

      it "is released by default" do
        lock = RedisLock.new({ 'timeout' => 500, 'name' => 'lock-name' }, [])
        refute lock.acquired?
      end

      it "can accept block as arguments" do
        lock = RedisLock.new({
            'timeout' => proc { |options| options['timeout'] * 2 },
            'name'    => proc { |options| "#{options['test']}-sidekiq" },
            'value'    => proc { |options| "#{options['test']}-sidekiq" }
          }, ['timeout' => 500, 'test' => 'hello'])

        assert_equal 1000, lock.timeout
        assert_equal 'hello-sidekiq', lock.name
        lock.acquire!
        assert_equal 'hello-sidekiq', redis("get", lock.name)
        lock.release!
      end

      it "can acquire a lock" do
        lock = RedisLock.new({'timeout' => 100, 'name' => 'test-lock'}, [])
        assert lock.acquire!
      end

      it "sets proper lock value on first and second acquire" do
        lock = RedisLock.new({'timeout' => 1000, 'name' => 'test-lock', 'value' => 'lock value'}, [])
        assert lock.acquire!
        assert_equal 'lock value', redis("get", lock.name)
        assert lock.release!
        # at this point script should be used from evalsha
        assert lock.acquire!
        assert_equal 'lock value', redis("get", lock.name)

        redis("script", "flush")
        assert lock.acquire!
        assert_equal 'lock value', redis("get", lock.name)
      end

      it "cannot acquire lock if it's already taken by other process/thread" do
        faster_lock = RedisLock.new({'timeout' => 100, 'name' => 'test-lock'}, [])
        assert faster_lock.acquire!

        slower_lock = RedisLock.new({'timeout' => 100, 'name' => 'test-lock'}, [])
        refute slower_lock.acquire!
      end

      it "releases taken lock" do
        lock = RedisLock.new({'timeout' => 100, 'name' => 'test-lock'}, [])
        lock.acquire!
        assert redis("get", "test-lock")

        assert lock.release!
        assert_nil redis("get", "test-lock")
      end

      it "releases lock taken by another process without deleting lock key" do
        lock = RedisLock.new({'timeout' => 100, 'name' => 'test-lock'}, [])
        lock.acquire!
        lock_value = redis("get", "test-lock")
        assert lock_value
        sleep 0.11 # timeout lock

        new_lock = RedisLock.new({'timeout' => 100, 'name' => 'test-lock'}, [])
        new_lock.acquire!
        new_lock_value = redis("get", "test-lock")

        refute lock.release!

        assert_equal new_lock_value, redis("get", "test-lock")
      end

      it "releases taken lock" do
        lock = RedisLock.new({'timeout' => 100, 'name' => 'test-lock', 'value' => 'custom_value'}, [])
        lock.acquire!
        assert redis("get", "test-lock")

        lock.release!
        assert_nil redis("get", "test-lock")
      end
    end
  end
end
