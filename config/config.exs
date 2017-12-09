use Mix.Config
config :pubsub,
  scheme: :http,
  host: "localhost",
  port: 8085,
  project: "elixir-pubsub"

config :goth,
  json: "/Users/cjab/Downloads/elixir-pubsub-b5422e66ef94.json" |> File.read!()
