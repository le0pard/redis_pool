defmodule RedisPool do
  use Application.Behaviour

  def start(_type, _args) do
    RedisPool.Supervisor.start_link()
  end

  def stop(_state) do
    :ok
  end
end
