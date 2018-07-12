require "test_helper"
require "sidekiq/lock/testing/inline"

describe "inline test helper" do
  after { reset_lock_variable! }

  it "has helper fuction for setting lock" do
    Sidekiq::Lock::RedisLock
      .expects(:new)
      .with({ timeout: 1, name: 'lock-worker' }, 'worker argument')
      .returns('lock set')

    set_sidekiq_lock(LockWorker, 'worker argument')
    assert_equal 'lock set', lock_container_variable
  end

  it "has helper fuction for clearing lock" do
    set_lock_variable! "test"
    assert_equal "test", lock_container_variable

    clear_sidekiq_lock
    assert_nil lock_container_variable
  end
end
