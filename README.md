# Weddell

Weddell is an Elixir client for [Google Pubsub](https://cloud.google.com/pubsub/).

Documentation can be found at: [https://hex.pm/weddell](https://hex.pm/weddell).
Code can be found at: [https://github.com/cjab/weddell](https://github.com/cjab/weddell).

## Installation

1) Add weddell to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:weddell, "~> 0.1.0"}]
end
```

2) Configure Goth with your GCP service account credentials:

```elixir
config :goth,
  json: {:system, "GCP_CREDENTIALS_JSON"}
```

## Getting Started

### Creating a consumer

```elixir
# In your application code
defmodule MyApp.Consumer do
  use Weddell.Consumer

  def handle_messages(messages) do
    # Process messages
    {:ok, ack: ack_messages, delay: delay_messages}
  end
end

defmodule MyApp do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {MyApp.Consumer, "subscription-name"}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### Publishing a message

```elixir
Weddell.create_topic("topic-name")
Weddell.create_subscription("subscription-name")
Weddell.publish("data", "topic-name")
```

## Alternatives

Weddell uses Pubsub's GRPC API which is still in beta. It also
makes use of streaming APIs that are considered experimental. If the
beta/experimental status of Weddell worries you [Kane](https://github.com/peburrows/kane)
may be a better choice. It uses the more mature Pubsub REST API.
