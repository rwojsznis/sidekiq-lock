## 0.2.0

- ability to globally configure `lock` method name

``` ruby
Sidekiq.configure_server do |config|
  config.lock_method = :redis_lock
end
```

- added inline test helper, by requiring `sidekiq/lock/testing/inline`
  you will have access to two methods:

  - `set_sidekiq_lock(worker_class, payload)`

  - `clear_sidekiq_lock`

  That will setup `RedisLock` under proper thread variable.
  This can be handy if you test your workers inline (without full stack middleware)

## 0.0.1

- Initial release
