use Mix.Config
config :pubsub,
# host: "localhost",
# port: 4343,
  ca_path: "/usr/local/etc/openssl/cert.pem",
  project: "elixir-pubsub"

config :goth,
  json: "/Users/cjab/Downloads/elixir-pubsub-b5422e66ef94.json" |> File.read!()
