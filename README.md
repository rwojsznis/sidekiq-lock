<p align="center">
  <img width="300" height="210" src="https://github.com/emq/sidekiq-lock/raw/master/logo.png">
</p>

# Sidekiq::Lock

[![Code Climate](https://codeclimate.com/github/emq/sidekiq-lock.png)](https://codeclimate.com/github/emq/sidekiq-lock)
[![Build Status](https://travis-ci.com/rwojsznis/sidekiq-lock.svg?branch=master)](https://travis-ci.com/rwojsznis/sidekiq-lock)
[![Gem Version](https://badge.fury.io/rb/sidekiq-lock.png)](http://badge.fury.io/rb/sidekiq-lock)

**Note:** This is a _complete_ piece of software, it should work across all future sidekiq & ruby versions.

Redis-based simple locking mechanism for [sidekiq][2]. Uses [SET command][1] introduced in Redis 2.6.16.

It can be handy if you push a lot of jobs into the queue(s), but you don't want to execute specific jobs at the same
time - it provides a `lock` method that you can use in whatever way you want.

## Installation

This gem requires at least:
- redis 2.6.12
- redis-rb 3.0.5 (support for extended SET method)

Add this line to your application's Gemfile:

``` ruby
gem 'sidekiq-lock'
```

And then execute:

``` bash
$ bundle
```

## Usage

Sidekiq-lock is a middleware/module combination, let me go through my thought process here :).

In your worker class include `Sidekiq::Lock::Worker` module and provide `lock` attribute inside `sidekiq_options`,
for example:

``` ruby
class Worker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker

  # static lock that expires after one second
  sidekiq_options lock: { timeout: 1000, name: 'lock-worker' }

  def perform
    # ...
  end
end
```

What will happen is:

- middleware will setup a `Sidekiq::Lock::RedisLock` object under `Thread.current[Sidekiq::Lock::THREAD_KEY]`
(it should work in most use cases without any problems - but it's configurable, more below) - assuming you provided
`lock` options, otherwise it will do nothing, just execute your worker's code

- `Sidekiq::Lock::Worker` module provides a `lock` method that just simply points to that thread variable, just as
a convenience

So now in your worker class you can call (whenever you need):

- `lock.acquire!` - will try to acquire the lock, if returns false on failure (that means some other process / thread
took the lock first)
- `lock.acquired?` - set to `true` when lock is successfully acquired
- `lock.release!` - deletes the lock (only if it's: acquired by current thread and not already expired)

### Lock options

sidekiq_options lock will accept static values or `Proc` that will be called on argument(s) passed to `perform` method.

- timeout - specified expire time, in milliseconds
- name - name of the redis key that will be used as lock name
- value - (optional) value of the lock, if not provided it's set to random hex

Dynamic lock example:

``` ruby
class Worker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  sidekiq_options lock: {
    timeout: proc { |user_id, timeout| timeout * 2 },
    name:    proc { |user_id, timeout| "lock:peruser:#{user_id}" },
    value:   proc { |user_id, timeout| "#{user_id}" }
  }

  def perform(user_id, timeout)
    # ...
    # do some work
    # only at this point I want to acquire the lock
    if lock.acquire!
      begin
        # I can do the work
        # ...
      ensure
        # You probably want to manually release lock after work is done
        # This method can be safely called even if lock wasn't acquired
        # by current worker (thread). For more references see RedisLock class
        lock.release!
      end
    else
      # reschedule, raise an error or do whatever you want
    end
  end
end
```

Just be sure to provide valid redis key as a lock name.

### Customizing lock method name

You can change `lock` to something else (globally) in sidekiq server configuration:

``` ruby
Sidekiq.configure_server do |config|
  config.lock_method = :redis_lock
end
```

### Customizing lock _container_

If you would like to change default behavior of storing lock instance in `Thread.current` for whatever reason you
can do that as well via server configuration:

``` ruby
# Any thread-safe class that implements .fetch and .store methods will do
class CustomStorage
  def fetch
    # returns stored lock instance
  end
  
  def store(lock_instance)
    # store lock
  end
end

Sidekiq.configure_server do |config|
  config.lock_container = CustomStorage.new
end
```

### Inline testing

As you know middleware is not invoked when testing jobs inline, you can require in your test/spec helper file
`sidekiq/lock/testing/inline` to include two methods that will help you setting / clearing up lock manually:

- `set_sidekiq_lock(worker_class, payload)` - note: payload should be an array of worker arguments
- `clear_sidekiq_lock`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: http://redis.io/commands/set
[2]: https://github.com/mperham/sidekiq
