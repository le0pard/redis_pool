defmodule RedisPool.Mixfile do
  use Mix.Project

  def project do
    [ app: :redis_pool,
      version: "0.2.6",
      elixir: "> 1.0.0",
      description: description(),
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps() ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: {RedisPool, []},
      applications: [:kernel, :stdlib]
    ]
  end

  defp description do
    """
    Redis pool for Elixir. Build on top of eredis and poolboy.
    """
  end

  defp package do
    [
      files: ["lib", "test", "mix.exs", "README.md"],
      maintainers: ["Alexey Vasiliev"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/le0pard/redis_pool",
        "Docs" => "http://leopard.in.ua/redis_pool/"
      }
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
      { :poolboy, "~> 1.5" },
      { :ex_doc, ">= 0.0.0", only: :dev }
    ]
  end
end
