defmodule RedisPool.Supervisor do
  use Supervisor

  def start_link do
    pools = Application.get_env(:redis_pool, :pools, [])
    global_or_local = Application.get_env(:redis_pool, :global_or_local, :global)
    start_link(pools, global_or_local)
  end

  def start_link(pools, global_or_local) do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [pools, global_or_local])
  end

  def create_pool(pool_name, size, options) do
    pool_name_scope = Application.get_env(:redis_pool, :global_or_local, :global)
    name = case pool_name do
      n when is_atom(n) ->
        {pool_name_scope, n}
      n -> n
    end

    args = [
      {:name, name},
      {:worker_module, :eredis},
      {:size, size},
      {:max_overflow, 10}]
    pool_spec = :poolboy.child_spec(pool_name, args, options)
    :supervisor.start_child(__MODULE__, pool_spec)
  end

  def delete_pool(pool_name) do
    :supervisor.terminate_child(__MODULE__, pool_name)
    :supervisor.delete_child(__MODULE__, pool_name)
  end

  def init([pools, global_or_local]) do
    spec_fun = fn({pool_name, pool_config}) ->
      args = [{:name, {global_or_local, pool_name}}, {:worker_module, :eredis}] ++ pool_config
      :poolboy.child_spec(pool_name, args, pool_config)
    end
    pool_specs = Enum.map(pools, spec_fun)

    supervise(pool_specs, strategy: :one_for_one)
  end

end
