defmodule Weddell.Mixfile do
  use Mix.Project

  @version "0.1.3"

  def project do
    [
      app: :weddell,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "Weddell",
      description: description(),
      source_url: "https://github.com/cjab/weddell",
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Weddell, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # GRPC
      {:protobuf, "~> 0.7"},
      {:grpc, "~> 0.3"},
      {:certifi, "~> 2.5"},

      # Testing
      {:mox, "~> 0.4", only: :test},
      {:uuid, "~> 1.1", only: :test},
      {:wait_for_it, "~> 1.1", only: :test},
      {:apex, "~> 1.2", only: [:test, :dev]},

      # Dev
      {:ex_doc, "~> 0.21", only: :dev},
      {:inch_ex, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A Google Pub/Sub library for Elixir"
  end

  defp package do
    [
      maintainers: ["Chad Jablonski"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/cjab/weddell"}
    ]
  end
end
