defmodule Pubsub.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pubsub,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Pubsub, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:protobuf, "~> 0.5"},
      {:grpc, github: "tony612/grpc-elixir", branch: :master},
      {:goth, "~> 0.7"},
      {:certifi, "~> 2.0"},
      {:apex, "~> 1.2", only: :dev},
      {:mox, "~> 0.3", only: :test},
    ]
  end
end
