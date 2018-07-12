def set_sidekiq_lock(worker_class, payload)
  options = worker_class.get_sidekiq_options['lock']
  Sidekiq.lock_container.store(Sidekiq::Lock::RedisLock.new(options, payload))
end

def clear_sidekiq_lock
  Sidekiq.lock_container.store(nil)
end
