def set_sidekiq_lock(worker_class, payload)
  options = worker_class.get_sidekiq_options['lock']
  Thread.current[Sidekiq::Lock::THREAD_KEY] = Sidekiq::Lock::RedisLock.new(options, payload)
end

def clear_sidekiq_lock
  Thread.current[Sidekiq::Lock::THREAD_KEY] = nil
end
