## 0.2.0 (in progress)

- ability to globally configure `lock` method name

``` ruby
Sidekiq.configure_server do |config|
  config.lock_method = :redis_lock
end
```

## 0.0.1

- Initial release
