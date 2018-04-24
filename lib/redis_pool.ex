defmodule RedisPool do
  use Application

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
    RedisPool.Supervisor.create_pool(pool_name, size, [{:host, host}, {:port, port}])
  end

  def create_pool(pool_name, size, host, port, database) do
    RedisPool.Supervisor.create_pool(pool_name, size, [{:host, host}, {:port, port}, {:database, database}])
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
    q(pool_name, command, timeout())
  end

  def q(pool_name, command, timeout) do
    pool_name = resolve_name(pool_name)
    :poolboy.transaction(pool_name, fn(worker) -> :eredis.q(worker, command, timeout) end)
  end

  def qp(pool_name, pipeline) do
    qp(pool_name, pipeline, timeout())
  end

  def qp(pool_name, pipeline, timeout) do
    pool_name = resolve_name(pool_name)
    :poolboy.transaction(pool_name, fn(worker) -> :eredis.qp(worker, pipeline, timeout) end)
  end

  def transaction(pool_name, fun) when is_function(fun) do
    f = fn(c) ->
      try do
        {:ok, _} = :eredis.q(c, ["MULTI"])
        fun.(c)
        :eredis.q(c, ["EXEC"])
      rescue
        error ->
          {:ok, _} = :eredis.q(c, ["DISCARD"])
          {:error, error}
      end
    end
    pool_name = resolve_name(pool_name)
    :poolboy.transaction(pool_name, f)
  end


  defp timeout do
    5000
  end

  defp resolve_name(name) when is_atom(name) do
    case Application.get_env(:redis_pool, :global_or_local, :global) do
      :global ->
        {:global, name}
      :local ->
        name
    end
  end
  defp resolve_name(name), do: name

end
