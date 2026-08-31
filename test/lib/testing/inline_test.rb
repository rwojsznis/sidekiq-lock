# frozen_string_literal: true

require "test_helper"
require "sidekiq/lock/testing/inline"

if Sidekiq.respond_to?(:testing!)
  Sidekiq.testing!(:fake)
else
  require "sidekiq/testing"
end

describe "inline test helper" do
  after { reset_lock_variable! }

  it "has helper function for setting lock" do
    set_sidekiq_lock(LockWorker, ['worker argument'])

    assert_kind_of Sidekiq::Lock::RedisLock, lock_container_variable
    assert_equal 'lock-worker', lock_container_variable.name
    assert_equal 1, lock_container_variable.timeout
  end

  it "provides a manually configured lock to a directly executed worker" do
    set_sidekiq_lock(InlineLockWorker, ['manual'])

    InlineLockWorker.new.perform('manual')

    assert_equal ['inline-lock-manual', 1000], InlineLockWorker.observed_lock
  ensure
    InlineLockWorker.observed_lock = nil
  end

  it "has helper function for clearing lock" do
    set_lock_variable! "test"
    assert_equal "test", lock_container_variable

    clear_sidekiq_lock
    assert_nil lock_container_variable
  end

  it "provides the lock during perform_inline" do
    skip 'perform_inline is unavailable in this Sidekiq version' unless InlineLockWorker.respond_to?(:perform_inline)

    chain = Sidekiq.default_configuration.server_middleware
    middleware_added = !chain.exists?(Sidekiq::Lock::Middleware)
    chain.add Sidekiq::Lock::Middleware if middleware_added

    InlineLockWorker.perform_inline('direct')

    assert_equal ['inline-lock-direct', 1000], InlineLockWorker.observed_lock
    assert_nil lock_container_variable
  ensure
    chain&.remove(Sidekiq::Lock::Middleware) if middleware_added
    InlineLockWorker.observed_lock = nil
  end

  it "provides the lock during Sidekiq testing inline execution" do
    Sidekiq::Testing.server_middleware do |chain|
      chain.add Sidekiq::Lock::Middleware unless chain.exists?(Sidekiq::Lock::Middleware)
    end

    Sidekiq::Testing.inline! do
      InlineLockWorker.perform_async('testing')
    end

    assert_equal ['inline-lock-testing', 1000], InlineLockWorker.observed_lock
    assert_nil lock_container_variable
  ensure
    Sidekiq::Testing.server_middleware do |chain|
      chain.remove(Sidekiq::Lock::Middleware)
    end
    InlineLockWorker.observed_lock = nil
  end
end
