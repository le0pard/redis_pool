defmodule RedisPool.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    {:ok, pools} = :application.get_env(:eredis_pool, :pools)
    {:ok, global_or_local} = :application.get_env(:eredis_pool, :global_or_local)
    start_link(pools, global_or_local)
  end

  def start_link(pools, global_or_local) do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [pools, global_or_local])
  end

  def create_pool(pool_name, size, options) do
    pool_spec = {pool_name, {:poolboy, :start_link,
      [{:name, {:global, pool_name}}, {:worker_module, :eredis}, {:size, size}, {:max_overflow, 10}]},
      :permanent, 5000, :worker, [:poolboy, :eredis]} ++ options
    :supervisor.start_child(__MODULE__, pool_spec)
  end

  def delete_pool(pool_name) do
    :supervisor.terminate_child(__MODULE__, pool_name)
    :supervisor.delete_child(__MODULE__, pool_name)
  end

  def init([pools, global_or_local]) do
    restart_strategy = :one_for_one
    max_restarts = 10
    max_seconds_between_restarts = 10
    sup_flags = {restart_strategy, max_restarts, max_seconds_between_restarts}

    restart = :permanent
    shutdown = 5000
    type = :worker

    spec_fun = fn({pool_name, pool_config}) ->
      args = [{:name, {global_or_local, pool_name}}, {:worker_module, :eredis}] ++ pool_config
      {pool_name, {:poolboy, :start_link, [args]}, restart, shutdown, type, []}
    end
    pool_specs = Enum.map(pools, spec_fun)

    {:ok, {sup_flags, pool_specs}}
  end

end