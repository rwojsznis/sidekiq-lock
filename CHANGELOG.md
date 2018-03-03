## 0.3.1 (March 3, 2018)

- do not assume ActiveSupport is loaded / or old Sidekiq patches are present (add own symbolize keys logic)
- make `options` and `payload` attr readers as `private` in `RedisLock` as it should be - **potentially breaking change** if you were accessing those (abusing) somehow for whatever reason (that shouldn't happen in the first place!)
- run test on travis for sidekiq `2.17`, `3.5`, `4.2` and `>= 5.1` and all newest rubies (`2.2` - `2.5`)

## 0.3.0 (July 28, 2016)

- ability to set custom lock value. Works just like setting timeout and name (handles procs as well).

``` ruby
sidekiq_options lock: {
    timeout: timeout,
    name:    name,
    value:   custom_value
  }
```

## 0.2.0 (December 08, 2013)

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

## 0.0.1 (October 14, 2013)

- Initial release
