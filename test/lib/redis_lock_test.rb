require "test_helper"

module Sidekiq
  module Lock
    describe RedisLock do
      before do
        Sidekiq.redis = REDIS
        Sidekiq.redis { |c| c.flushdb }
      end

      let(:args) { [{'timeout' => 100, 'name' => 'test-lock'}, []] }

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
            'name'    => proc { |options| "#{options['test']}-sidekiq" }
          }, ['timeout' => 500, 'test' => 'hello'])

        assert_equal 1000, lock.timeout
        assert_equal 'hello-sidekiq', lock.name
      end

      it "can acquire a lock" do
        lock = RedisLock.new(*args)
        assert lock.acquire!
      end

      it "cannot aquire lock if it's already taken by other process/thread" do
        faster_lock = RedisLock.new(*args)
        assert faster_lock.acquire!

        slower_lock = RedisLock.new(*args)
        refute slower_lock.acquire!
      end

      it "releases taken lock" do
        lock = RedisLock.new(*args)
        lock.acquire!
        assert redis("get", "test-lock")

        lock.release!
        assert_nil redis("get", "test-lock")
      end

      it "releases lock taken by another process without deleting lock key" do
        lock = RedisLock.new(*args)
        lock.acquire!
        lock_value = redis("get", "test-lock")
        assert lock_value
        sleep 0.11 # timeout lock

        new_lock = RedisLock.new(*args)
        new_lock.acquire!
        new_lock_value = redis("get", "test-lock")

        lock.release!

        assert_equal new_lock_value, redis("get", "test-lock")
      end
    end
  end
end
