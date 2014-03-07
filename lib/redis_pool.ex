defmodule RedisPool do
  use Application.Behaviour

  def start(_type, _args) do
    RedisPool.Supervisor.start_link()
  end

  def stop(_state) do
    :ok
  end

  def start do
    :application.start(__MODULE__)
  end

  def stop do
    :application.stop(__MODULE__)
  end

  def create_pool(pool_name, size) do
    RedisPool.Supervisor.create_pool(pool_name, size, [])
  end

  def create_pool(pool_name, size, host) do
    RedisPool.Supervisor.create_pool(pool_name, size, [{:host, host}])
  end

  def create_pool(pool_name, size, host, port) do
    RedisPool.Supervisor.create_pool(pool_name, size,
      [{:host, host}, {:port, port}])
  end

  def create_pool(pool_name, size, host, port, database) do
    RedisPool.Supervisor.create_pool(pool_name, size,
      [{:host, host}, {:port, port}, {:database, database}])
  end

  def create_pool(pool_name, size, host, port, database, password) do
    RedisPool.Supervisor.create_pool(pool_name, size,
      [{:host, host}, {:port, port}, {:database, database}, {:password, password}])
  end

  def create_pool(pool_name, size, host, port, database, password, reconnect_sleep) do
    RedisPool.Supervisor.create_pool(pool_name, size,
      [{:host, host}, {:port, port}, {:database, database}, {:password, password}, {:reconnect_sleep, reconnect_sleep}])
  end

  def delete_pool(pool_name) do
    RedisPool.Supervisor.delete_pool(pool_name)
  end

  def q(pool_name, command) do
    q(pool_name, command, timeout)
  end

  def q(pool_name, command, timeout) do
    :poolboy.transaction(pool_name, fn(worker) -> :eredis.q(worker, command, timeout) end)
  end

  def qp(pool_name, pipeline) do
    qp(pool_name, pipeline, timeout)
  end

  def qp(pool_name, pipeline, timeout) do
    :poolboy.transaction(pool_name, fn(worker) -> :eredis.qp(worker, pipeline, timeout) end)
  end

  def transaction(pool_name, fun) when is_function(fun) do
    f = fn(c) ->
      try do
        {:ok, _} = :eredis.q(c, ["MULTI"])
        fun.(c)
        :eredis.q(c, ["EXEC"])
      rescue error in [c] ->
        {:ok, _} = :eredis.q(c, ["DISCARD"])
        {:error, error}
      end
    end
    :poolboy.transaction(pool_name, f)
  end


  defp timeout do
    5000
  end

end