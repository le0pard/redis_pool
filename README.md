# RedisPool for Elixir
[![Build Status](https://travis-ci.org/le0pard/redis_pool.png?branch=master)](https://travis-ci.org/le0pard/redis_pool)

This is redis pool for [Elixir](http://elixir-lang.org/). Build on top of [eredis](https://github.com/wooga/eredis) and [poolboy](https://github.com/devinus/poolboy).

## Examples

Application start:

```
RedisPool.start
```
or add it in `application` section in mix:

```
def application do
  [mod: {Example, []},
   applications: [ :redis_pool ] ]
end
```

### Create pools

```
RedisPool.create_pool(:default, 10)

RedisPool.create_pool(:test, 10, 'localhost', 6379)

RedisPool.create_pool(:test2, 10, 'localhost', 6379, 0, 'password', 100)
```

Also you can configure redis_pool directly from configuration file to get pools automatically created at application startup. In `config/config.exs`, add :

```
config :redis_pool, :pools, [
  test_pool:   [size: 10, host: '127.0.0.1', port: 6379],
  test_pool_2: [size: 20, host: '127.0.0.1', port: 6379, database: 'user_db', password: 'abc', reconnect_sleep: '20']
]
```

### Delete pools

```
RedisPool.delete_pool(:default)

RedisPool.delete_pool(:test)
```

### Usage

Usage of pools:

```
RedisPool.q({:global, :default}, ["SET", "foo", "bar"])

RedisPool.q({:global, :test}, ["GET", "foo"])
```

Method `transaction` is execute all redis command between `MULTI` and `EXEC` commands:

```
RedisPool.transaction {:global, :redis}, fn(redis) ->
  :eredis.q redis, ["SADD", "queues", queue]
  :eredis.q redis, ["LPUSH", "queue", "Test" ]
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
