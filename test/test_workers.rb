# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'sidekiq-lock'

class LockWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  sidekiq_options lock: { timeout: 1, name: 'lock-worker' }
end

class DynamicLockWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  sidekiq_options lock: {
    timeout: proc { |user_id, timeout| timeout*2 },
    name:    proc { |user_id, timeout| "lock:#{user_id}" }
  }
end

class RegularWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
end

class InlineLockWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  sidekiq_options lock: { timeout: 1000, name: proc { |argument| "inline-lock-#{argument}" } }

  class << self
    attr_accessor :observed_lock
  end

  def perform(argument)
    self.class.observed_lock = [lock.name, lock.timeout]
  end
end
