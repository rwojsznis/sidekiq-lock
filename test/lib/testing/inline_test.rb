# frozen_string_literal: true

require "test_helper"
require "sidekiq/lock/testing/inline"

describe "inline test helper" do
  after { reset_lock_variable! }

  it "has helper function for setting lock" do
    set_sidekiq_lock(LockWorker, ['worker argument'])

    assert_kind_of Sidekiq::Lock::RedisLock, lock_container_variable
    assert_equal 'lock-worker', lock_container_variable.name
    assert_equal 1, lock_container_variable.timeout
  end

  it "has helper function for clearing lock" do
    set_lock_variable! "test"
    assert_equal "test", lock_container_variable

    clear_sidekiq_lock
    assert_nil lock_container_variable
  end
end
