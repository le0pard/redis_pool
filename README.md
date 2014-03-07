# RedisPool for Elixir

This is redis pool for [Elixir](http://elixir-lang.org/). It build on top of eredis and poolboy.

## Examples

application start:

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

Create pool:

```
RedisPool.create_pool(:default, 10)

RedisPool.create_pool(:test, 10, "localhost", 6379)
```

And use it:

```
RedisPool.q({:global, :default}, ["SET", "foo", "bar"])

RedisPool.q({:global, :test}, ["GET", "foo"])

RedisPool.transaction {:global, :redis}, fn(redis) ->
  :eredis.q redis, ["SADD", "queues", queue]
  :eredis.q redis, ["LPUSH", "queue", "Test" ]
end
```
