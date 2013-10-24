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
