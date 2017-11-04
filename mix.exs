defmodule Pubsub.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pubsub,
      version: "0.1.0",
      elixir: "~> 1.5",
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:protobuf, "~> 0.3"},
      {:grpc, path: "../grpc-elixir"},
    ]
  end
end
