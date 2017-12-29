defmodule Weddell.Mixfile do
  use Mix.Project

  def project do
    [
      app: :weddell,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      name: "Weddell",
      description: description(),
      source_url: "https://github.com/cjab/weddell",
      docs: [main: "README",
             extras: ["README.md"]]
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
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:protobuf, "~> 0.5"},
      {:grpc, github: "tony612/grpc-elixir", branch: :master},
      {:certifi, "~> 2.0"},
      {:apex, "~> 1.2", only: :dev},
      {:mox, "~> 0.3", only: :test},
      {:uuid, "~> 1.1", only: :test},
      {:wait_for_it, github: "cjab/wait_for_it", branch: "update-ex-doc", only: :test},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
    ]
  end

  defp description do
    "A Google Pub/Sub library for Elixir"
  end

  defp package do
    [
      maintainers: ["Chad Jablonski"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/cjab/weddell"},
    ]
  end
end
