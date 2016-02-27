defmodule RedisPool.Mixfile do
  use Mix.Project

  def project do
    [ app: :redis_pool,
      version: "0.2.3",
      elixir: "~> 1.2",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: {RedisPool, []},
      applications: [:kernel, :stdlib]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      { :eredis, "~> 1.0" },
      { :poolboy, "~> 1.5" }
    ]
  end
end
