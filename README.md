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

Also you can set enviroment variables to create pool, when application start:

```
{env, [
        {pools, [
                 {pool1, [
                            {size, 30},
                            {max_overflow, 20},
                            {host, "127.0.0.1"},
                            {port, 6379}
                           ]},
                 {pool2, [
                            {size, 20},
                            {max_overflow, 20},
                            {host, "127.0.0.1"},
                            {port, 6379},
                            {database, "user_db"},
                            {password, "abc"},
                            {reconnect_sleep, 100}
                           ]}
                ]}
      ]}
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